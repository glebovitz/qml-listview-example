import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.0

ListView {
    id: propertyListView

    property bool loading : true
    property var data : null
    property var dataSource : cloneWithRows(this.props.data || this._genDummyData())
    property bool initialized : false
    property string type : 'recent'
    property string title : 'Loading, please wait...'
    property int page : 1
    property int limit : 16
    property bool isSearchMenuOpen : false
    property bool isMenuOpen: false

    function getLimitedData(page, data, limit) {
        if (page == null) {
            page = propertyListView.page;
        }

        data = propertyListView.data, limit = null
        if (!data || data.length == 0) return [];
        
        if (limit) {
            return data.slice(this.state.limit * (page - 1), this.state.limit * (page - 1) + limit);
        }

        return data.slice(Math.max(this.state.limit * (page - 2), 0), this.state.limit * page);
    }

    
    function componentDidMount() {
        var that = this,
                params = this.lastParams || {},
        type = this.state.type,
                itemExtWrappers = [];

        setTimeout(function(e)
        {

            if (type == "map" && params.coords){
                params.query = app.ui.formatting.coordinateString(params.coords);
            }

            if (type == "nearby"){
                app.location.me.requestLocation(function(){
                    this.performSearchRequest(params, type, null, function(){
                        // Fall back to recent if no results found nearby
                        this.performSearchRequest(params, 'recent', null, null, "Recent Properties");
                        return false;
                    }.bind(this));

                }.bind(this));


                //    app.ui.c.$window.on('setlocation', function(evt, evtData){
                //        if (evtData.set) {
                //            // User location coordinates were set
                //            that.loadFromServer(type, function(data){
                //                if (data.results.length == 0){
                //                    // Fall back to recent properties if no properties found nearby.
                //                    recentPropertiesRequest();
                //                } else {
                //                    that.setState({
                //                        title: "Nearby " + data.results[0].address.town.trim(),
                //                        data: data.results
                //                    });
                //                    if (app.ui.elems.offCanvasSearch != null) app.ui.elems.offCanvasSearch.forceUpdate();
                //
                //                }
                //            }, params);
                //        } else {
                //            // Fall back to recent properties if user didn't allow access to location.
                //            recentPropertiesRequest();
                //        }
                //    });

            } else if (type == 'search' || type == 'map'){
                if (params.coords && typeof params.coords.latitude == 'number' && typeof params.coords.longitude == 'number'){
                    if (type == 'search'){
                        app.location.search.coordinates = params.coords;
                        app.location.search.hasBeenSet = true;
                    } else {
                        app.location.listings_map.coordinates = params.coords;
                        app.location.listings_map.hasBeenSet = true;
                    }
                    app.ui.elems.offCanvasSearch.lastSearchQuery = params.query;
                    app.location.search.formatted = params.query;
                }
                app.ui.elems.offCanvasSearch.doSearch(params, this, type);
            } else if (type == 'recent'){
                this.performSearchRequest(params, 'recent', null, null, "Recent Properties");
            }

        }, 100);
    }

    function componentWillUpdate(newProps, newState){
        /*
        if ('data' in newState){
            if (newState.data.length > newState.limit * 2){
                //let dif = newState.data.length - newState.limit * 2;
                //let difOffset = this.refs.propertyListView.scrollProperties.offset % (tileStyleVars.tileOuterHeight);
                
                //newState.data.splice(0, dif);
                //this.refs.propertyListView.scrollTo({x: 0, y: tileStyleVars.tileOuterHeight * (newState.limit * 2 - dif) + difOffset, animated: false});
                
            }
            newState.dataSource = this.ds.cloneWithRows(this.getLimitedData(newState.page, newState.data));
        }
        */
        if (newState.data != this.state.data){
            newState.dataSource = this.ds.cloneWithRows(newState.data);
        }
        
    }

    function componentDidUpdate() {
        
    }

    function performSearchRequest(params, typeOfQuery, callbackSuccess, callbackNoResults, titleOverride = null){
        propertyListView.isLoading = true;
        propertyListView.loadFromServer (
                    typeOfQuery,
                    function(data) {
                        if (data.results.length == 0){
                            let cont = true;
                            if (typeof callbackNoResults == 'function'){
                                cont = callbackNoResults(data);
                            }
                            if (cont) {
                                this.setState({
                                                  title : typeOfQuery == 'search' ?
                                                              "Nothing found near " + app.location.search.formatted : "No Results",
                                                              data : data.results,
                                                              page : params.page || 1,
                                                              loading : false,
                                                              initialized : true
                                              });
                            }
                        } else {
                            if (typeof callbackSuccess == 'function'){
                                callbackSuccess(data);
                            }
                            this.setState({
                                              data : data.results,
                                              title : titleOverride || (
                                                          typeOfQuery == 'recent' ?
                                                              'Recent Results' : typeOfQuery == 'nearby' ?
                                                                  'Nearby Results' : 'Results Near ' + app.ui.formatting.coordinateString(params.coords)
                                                          ),
                                              page : params.page || 1,
                                              loading : false,
                                              initialized : true
                                          });
                        }

                        setTimeout(function () {
                            this.isLoading = false;
                        }, 3000);

                    }.bind(this),params);
    }

    loadFromServer(type, extraCallback, params) {

        if (typeof type   == 'undefined') type = this.state.type || this.props.type || 'recent';
        if (typeof params == 'undefined') params = {};

        if (_.has(params, 'page') && params.page == 1) delete params.page; 

        this.lastParams = params;
        this.lastType = type; 
        
        setTimeout(()=>{
            fetch(this.typeToUrl(type, params))
            .then(response => response.json())
            .then(response => this._handleResponse(response, type, extraCallback))
            .catch(error => {
                    this.isLoading = false;
                    console.log(error);
                    this.setState({
                        message: 'Something bad happened ' + error,
                        loading : false
                    })
                }
            );
        }, 10);
    }

    typeToUrl(type, params){
        if (typeof type == 'undefined') type = this.state.type || this.props.type || 'recent';
        
        if (type == 'nearby') return app.data.domain + app.routes.nearbyProperties(true, this.state.limit, params);
        if (type == 'recent') return app.data.domain + app.routes.recentProperties(true, this.state.limit, params);
        if (type == 'search') return app.data.domain + app.routes.findAndFilter(true, this.state.limit, params);
        if (type == 'map') return app.data.domain + app.routes.mapSearch(true, this.state.limit, params);
    }

    _handleResponse(data, type, extraCallback){
        if (app.data.dev_mode) console.log('_handleResponse:');
        if (typeof extraCallback == 'function'){
            extraCallback(data, type);
        }
        if (typeof this.props.loadCallback == 'function') {
            this.props.loadCallback(data, type);
        }
    }

    loadMore(){
        if (this.isLoading || this.state.loading || this.state.data.length < this.state.limit * this.state.page) return false;
        
        let params = this.lastParams;
        params.page = this.state.page + 1;

        setTimeout((e)=>{
            let oldTitle = this.state.title;
            this.isLoading = true;
            this.setState({
                title : 'Loading, please wait...',
                loading : true
            });

            

            //this.refs.propertyListView.scrollTo({ x : 0, y: this.refs.propertyListView.scrollProperties.contentLength, animated : true});
            //console.log(this.refs.propertyListView);
            
            this.loadFromServer(
                this.lastType, 
                function(data){
                    //setTimeout((e)=>{
                        let newData = _.clone(this.state.data);
                        _.forEach(newData, (d)=>{
                            d.imagesHaveBeenLoaded = true;
                        });
                        _.forEach(data.results, (res)=>{
                            if (newData.indexOf(res) == -1) newData.push(res);
                        });
                        
                        this.setState({
                            data : newData,
                            page : this.state.page + 1, 
                            title : oldTitle,
                            loading : false
                        });

                        setTimeout((t)=>{
                            this.isLoading = false;
                        }, 3000, this);
                        
                    //}, 0);
                }.bind(this),
                params
            ); 
        }, 1000);
    }

    openSearchMenu(){
        this.refs.searchDrawer.open();
    }

    closeSearchMenu(){
        this.refs.searchDrawer.close();
    }
    
//    renderPropertyListing(propertyData, sectionID, rowID) {
//        return (
//            <PropertyListingItem
//                data={propertyData}
//                isLoaded={propertyData.imagesHaveBeenLoaded}
//                key={propertyData._id || rowID}
//                navigator={this.props.navigator}
//                getMapSection={(e)=>{return this.refs.mapSection}}
//                navigateTo={this.props.navigateTo}
//                openMapMarker={(propertyID)=>{

//                    let cb = function(){
//                        //this.props.navigator._navBar.setAnimated('show');
//                        this.refs.mapDrawer.open();
//                        //let selectedComponent = this.refs.mapSection.refs['marker-' + propertyID];
//                        //selectedComponent.dispatchEvent('select');
//                        this.refs.mapSection.openMarker(propertyID, null, true);
//                    }.bind(this);

//                    let page = parseInt((this.refs.propertyListView.scrollProperties.offset / tileStyleVars.tileOuterHeight) / this.state.limit) + 1;

//                    if (page != this.refs.mapSection.state.page){
//                        this.refs.mapSection.setState({
//                            page : page,
//                            data : this.getLimitedData(page)
//                        }, cb);
//                    } else {
//                        cb();
//                    }
                    
//                }}
//            />
//        );
//    }
    
                                    // renderPropertyListings(){
                                    //     if (this.state.loading && !this.state.initialized){
                                    //         return (
                                    //             <View style={styles.centeredContainer}>
                                    //                 <ActivityIndicator size='large'/>
                                    //             </View>
                                    //         );
                                    //     } else if (this.state.data.length == 0) {
                                    //         return (
                                    //             <View style={styles.centeredContainer}>
                                    //                 <Text>{ this.state.title }</Text>
                                    //             </View>
                                    //         );
                                    //     }

                                    //     return (<ListView
                                    //         ref="propertyListView"
                                    //         style={styles.propertyListView}
                                    //         contentContainerStyle={styles.propertyListViewContainer}
                                    //         dataSource={this.state.dataSource}
                                    //         renderRow={this.renderPropertyListing.bind(this)}
                                    //         horizontal={false}
                                    //         initialListSize={12}
                                    //         canCancelContentTouches={true}
                                    //         directionalLockEnabled={true}
                                    //         removeClippedSubviews={ true }
                                    //         scrollRenderAheadDistance={6000}
                                    //         onScrollEventThrottle={200}
                                    //         pageSize={6}
                                    //         contentInset={{top: 0, left: 0, right: 0, bottom: 10}}
                                    //         onScroll={this.props.onScroll}
                                    //         renderHeader={()=>{
                                    //             return (
                                    //                 <Text style={ styles.listViewTitle }>{ this.state.title }</Text>
                                    //             );
                                    //         }}
                                    //         renderFooter={()=>{
                                    //             if (!this.state.loading || this.state.data.length < this.state.page * this.state.limit) return false;
                                    //             return (
                                    //                 <ActivityIndicator size='large' style={{ marginTop: 20, marginBottom: 10 }}/>
                                    //             );
                                    //         }}
                                    //         renderScrollComponent={props => <RecyclerViewBackedScrollView {...props} />}
                                    //         scrollEnabled={true}
                                    //         onEndReached={(e)=>{
                                    //             //console.log('end');
                                    //             this.loadMore()
                                    //         }}
                                    //         onEndReachedThreshold={150}
                                    //     />);
                                    // }
    
    // render() {
    //     return (
    //         <Drawer 
    //             style={styles.pageContainer}
    //             ref="searchDrawer"
    //             content={<SearchSection getPropertyListingsView={ ()=> this } navigator={ this.props.navigator } />}
    //             type="static"
    //             openDrawerOffset={0.1}
    //             tapToClose={true}
    //             onOpen={this.props.searchDrawerOnOpen}
    //             onClose={this.props.searchDrawerOnClose}
    //             onOpenStart={(e)=>{
    //                 if (this.refs.mapDrawer._open){
    //                     this.refs.mapDrawer.close();
    //                 }
    //                 this.props.searchDrawerOnOpenStart()
    //             }}
    //             onCloseStart={this.props.searchDrawerOnCloseStart}
                
    //         >
    //             <View style={{ flex : 1 }}>
    //             <Drawer 
    //                 style={styles.pageContainer}
    //                 ref="mapDrawer"
    //                 side="right"
    //                 content={
    //                     <MapSection 
    //                         data={/*this.getLimitedData()*/ null} 
    //                         page={/*this.state.page*/ null} 
    //                         getLimitedData={this.getLimitedData.bind(this)}
    //                         type={this.state.type} 
    //                         ref="mapSection" 
    //                         navigateTo={this.props.navigateTo}
    //                     />
    //                 }
    //                 tapToClose={true}
                    
    //                 onOpen={this.props.mapDrawerOnOpen}
    //                 onClose={this.props.mapDrawerOnClose}
    //                 onOpenStart={(e)=>{
    //                     if (this.refs.searchDrawer._open){
    //                         this.refs.searchDrawer.close();
    //                     }
    //                     this.props.mapDrawerOnOpenStart();
    //                 }}
    //                 onCloseStart={this.props.mapDrawerOnCloseStart}
    //             >
    //                 <View style={{ flex : 1, backgroundColor : '#fff' }}>    
    //                     { this.renderPropertyListings() }
    //                 </View>
                    
    //             </Drawer>
    //             </View>
    //         </Drawer>
    //     );
    // }
    
    // _genDummyData(){
    //     var dummydata = [];
    //     for (var i = 0; i < 10; i++){
    //         dummydata.push({
    //             title : 'Loading.. ' + i,
    //             _id: 'd' + i,
    //             address: null,
    //             bedrooms: null,
    //             bathrooms: {
    //                 number_full : null,
    //                 number_half : null
    //             },
    //             photos: null,
    //             market_time : {
    //                 time : null 
    //             },
    //             parking: {
    //                 spaces: null
    //             },
    //             area: {
    //                 square_feet : null
    //             },
    //             amenities: '' 
    //         })
    //     }
    //     return dummydata;
    // }
}

const styles = StyleSheet.create({
    centeredContainer: {
        flex: 1,
        alignSelf : 'stretch',
        height: Dimensions.get('window').height - NavigatorNavigationBarStylesIOS.General.TotalNavHeight,
        width: Dimensions.get('window').width,
        justifyContent : 'center',
        alignItems : 'center',
        backgroundColor: '#F5FCFF',
        marginTop: NavigatorNavigationBarStylesIOS.General.TotalNavHeight
    },

    pageContainer: {
        flex: 1
    },

    propertyListView : {
        height: Dimensions.get('window').height,
        width: Dimensions.get('window').width,
        flex : 1,
        left : 0,
        right : 0,
        top : 0,
        bottom : 0,
        backgroundColor: '#fff'
    },

    listViewTitle : {
        padding : 10,
        paddingBottom : 2,
        fontWeight : '100',
        fontSize : 18
    },

    propertyListViewContainer : {
        marginTop: NavigatorNavigationBarStylesIOS.General.TotalNavHeight
    },

    welcome: {
        fontSize: 20,
        textAlign: 'center',
        margin: 10,
    },
    instructions: {
        textAlign: 'center',
        color: '#333333',
        marginBottom: 5,
    },
});
