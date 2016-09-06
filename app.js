.import Quickly 0.1 as Quickly

var Promise = Quickly.Polyfills.Promise
var Http = Quickly.Http
var Url = Quickly.Url

var app = {

    g : {},

    data : {
        dev_mode : true,
        property_photos_base_url : 'https://f000.backblaze.com/file/properties/',
        domain : 'https://tornado-intelliagent.rhcloud.com',
        user : null
    },
    
    routes: {
        propertiesBase : "/api/properties",
        locationBase   : "/api/location",
        
        appendParams :function(sep, photos_only, limit, params){
            if (typeof photos_only != 'boolean'){
                photos_only = false;
            }
            if (typeof limit != 'number'){
                limit = null;
            }
            var str = '';
            if (photos_only == true){
                 str += sep + 'photos_only=true';
            } else {
                 str += sep + 'photos_only=false';
            }
            if (limit != null){
                str += '&limit=' + limit;
            }
            if (typeof params == 'object'){
                _.forOwn(
                    params,
                    function(val,key){
                        if (key != 'coords' && key != 'query'){
                            str += '&' + key + '=' + val;
                        }
                    }
                )
            }
            
            return str;
        },
        
        nearbyProperties: function(photos_only, limit, params){
            if (app.location.me.hasBeenSet){
                return (
                    app.routes.propertiesBase + 
                    '/near?long=' + app.location.me.coordinates.longitude + 
                    '&lat=' + app.location.me.coordinates.latitude + 
                    app.routes.appendParams('&', photos_only, limit, params)
                );
            } else {
                return (
                    app.routes.propertiesBase + 
                    '/recent' + 
                    app.routes.appendParams('?', photos_only, limit, params)
                );
            }
        },
        
        recentProperties : function(photos_only, limit, params){ 
            if (typeof photos_only == 'undefined'){
                photos_only = false;
            } 
            return app.routes.propertiesBase + '/recent' + app.routes.appendParams('?', photos_only, limit, params); 
        },
        
        addressCoordinates : function(addressQuery){
            return (
                app.routes.locationBase + '/getcoords/' + addressQuery
            );
        },
        
        findAndFilter : function(photos_only, limit, params){
            if (!app.location.search.hasBeenSet) return app.routes.nearbyProperties(photos_only);
            return (
                app.routes.propertiesBase + 
                '/near?long=' + app.location.search.coordinates.longitude + 
                '&lat=' + app.location.search.coordinates.latitude + 
                app.routes.appendParams('&', photos_only, limit, params)
            );
        },
        
        mapSearch : function(photos_only, limit, params){
            return (
                app.routes.propertiesBase + 
                '/near?long=' + app.location.listings_map.coordinates.longitude + 
                '&lat=' + app.location.listings_map.coordinates.latitude + 
                app.routes.appendParams('&', photos_only, limit, params)
            );
        }
    },
    
    location : {
        
        search : {
        
            coordinates : {
                longitude : null,
                latitude: null 
            },
            
            hasBeenSet: false,
            
            requestCoordinatesForAddress: function(addressQuery, cb){
                if (app.data.dev_mode) { 
                    console.log("Requesting Google for address coords."); 
                    console.log(app.routes.addressCoordinates(addressQuery));
                }

                Http.fetch(app.data.domain + app.routes.addressCoordinates(addressQuery))
                .then(function(response){return response.json()}.bind(this))
                .then(function(response) {
                    if (app.data.dev_mode){
                        console.log('Response for getting address coords:');
                        console.log(response);
                    }
                    if (response.result.length > 0){
                        app.location.search.formatted = response.result[0].formatted_address;
                        app.location.search.coordinates.longitude = response.result[0].geometry.location.lng;
                        app.location.search.coordinates.latitude = response.result[0].geometry.location.lat;
                        app.location.search.hasBeenSet = true;
                    } else {
                        /* Show error: address not found */
                    }
                    
                    if (typeof cb == 'function'){
                        cb(response);
                    }
                }.bind(this))
                .catch(function(error) {
                    console.log(error);
                });
            },
            
        },
        
        listings_map : {
            
            coordinates: {
                longitude : null,
                latitude: null 
            },
            
            hasBeenSet: false
            
        },
        
        me : {
            
            coordinates: {
                longitude : null,
                latitude: null 
            },
            
            hasBeenSet: false,
            
            requestLocation : function(callback){
                if (app.location.me.hasBeenSet == true){
                    if (typeof callback == 'function'){
                        return callback(pos);
                    }
                    return true;
                }
                if (navigator.geolocation) {
                    navigator.geolocation.getCurrentPosition(
                        function(pos){
                            // Success
                            app.location.me.setCoords(pos);
                            if (typeof callback == 'function'){
                                return callback(pos);
                            }
                        },
                        function(e){
                            // Error
                            if (app.data.dev_mode) {
                                console.log(e);
                            }
                            Alert.alert(
                                'Location unavailable',
                                e.message
                            );
                            
                            //app.ui.c.$window.trigger('setlocation', { set: false, target: 'me' });
                        }
                    );
                    return true;
                }
                return false;
            },
            
            setCoords: function(position){
                app.location.me.coordinates.longitude = position.coords.longitude;
                app.location.me.coordinates.latitude = position.coords.latitude;
                app.location.me.hasBeenSet = true;
                //window.dispatchEvent(new Event('setlocation'));
                //app.ui.c.$window.trigger('setlocation', { set: true, target: 'me' });
            },
            
        }
        
    },

    ui : {
        
        formatting : {

            phoneNumber : function(phoneNumber, excludeOne){
                phoneNumber = phoneNumber + "";
                if (phoneNumber.length < 7) return phoneNumber;

                function formatNum(){
                    if (phoneNumber.charAt(0) == 1) {
                        return '(' + phoneNumber.slice(1,4) + ') ' + phoneNumber.slice(4,7) + '-' + phoneNumber.slice(7);
                    } else {
                        return '(' + phoneNumber.slice(0,3) + ') ' + phoneNumber.slice(3,6) + '-' + phoneNumber.slice(6);                    
                    }
                }
                

                if (typeof excludeOne == 'undefined' || !excludeOne) return '1 ' + formatNum();
                return formatNum();
            },
            
            time : function(dateObj){
                if (typeof dateObj == 'string') dateObj = new Date(dateObj);
                
                var now = new Date();
                var nowMs = now.getTime();
                var dateMs = dateObj.getTime();
                
                var h = dateObj.getHours(),
                    m = dateObj.getMinutes();
                    
                var amPm = 'AM';
                if (h > 12){
                    h = h - 12;
                    amPm = 'PM';
                } else if (h == 0){
                    h = 12;
                }
                
                if (m < 10) m = '0' + m;
                
                if (now.getDate() == dateObj.getDate()){
                    var s = dateObj.getSeconds()
                    if (s < 10) s = '0' + s;
                    return h + ':' + m + ':' + s + ' ' + amPm;
                } else if (nowMs - 172800000 <= dateMs) {
                    return 'Yesterday ' + h + ':' + m + ' ' + amPm;
                } else if (nowMs - 172800000 >= dateMs) {
                    return (dateObj.getMonth() + 1) + '/' + dateObj.getDate() + ' ' +  h + ':' + m + ' ' + amPm;
                }
            },
            
            streetAddress : function(propertyAddress){
                if (!propertyAddress) return null; 

                var streetAddr = (propertyAddress.street_number || propertyAddress.street_no) + 
                    " " + propertyAddress.street_name;
                if ('unit_number' in propertyAddress){
                    streetAddr += " #" + propertyAddress.unit_number;
                }
                return streetAddr;
            },

            townState: function(propertyAddress, shortenState){
                if (shortenState == null) shortenName = false;
                if (!propertyAddress) return null; 
                if (shortenState) return propertyAddress.town + ', ' + app.ui.formatting.shortenState(propertyAddress.state);
                return propertyAddress.town + ', ' + propertyAddress.state;
                
            },
            
            price: function(listPrice, includeDollarSign){
                var price = parseFloat(listPrice) || null;
                if (includeDollarSign == null) includeDollarSign = true;
                if (price == null) return null;
                if (price){
                    return (includeDollarSign ? '$' : '') + price.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
                }
                return price; 
            },

            bedroomsBathrooms: function(bedrooms, bathrooms){
                if (bedrooms == null){
                    return null;
                }
                bedrooms = parseInt(bedrooms.number);
                bathrooms = ( parseInt(bathrooms.number_full) + parseInt(bathrooms.number_half) / 2 );
                return bedrooms + " Br / " + bathrooms + " Ba"; 
            },

            coordinateString : function(coords){
                var lat = (Math.round(coords.latitude * 1000)/1000 + ''),
                    lng = (Math.round(coords.longitude * 1000)/1000 + '');
                    
                lat = lat.slice(0, lat.indexOf('.') + 4);
                lng = lng.slice(0, lng.indexOf('.') + 4);
                return lat + ', ' + lng;
            },

            shortenState : function(stateFullName){
                var state = _.find(app.ui.formatting.getStates(), { 'name' : stateFullName });
                if (state) {
                    return state.abbrev;
                }
                return stateFullName; // Fallback to orig.
            },

            getStates : function(){
                return [
                    {'name':'Alabama', 'abbrev':'AL'},
                    {'name':'Alaska', 'abbrev':'AK'},
                    {'name':'Arizona', 'abbrev':'AZ'},
                    {'name':'Arkansas', 'abbrev':'AR'},
                    {'name':'California', 'abbrev':'CA'},
                    {'name':'Colorado', 'abbrev':'CO'},
                    {'name':'Connecticut', 'abbrev':'CT'},
                    {'name':'Delaware', 'abbrev':'DE'},
                    {'name':'Florida', 'abbrev':'FL'},
                    {'name':'Georgia', 'abbrev':'GA'},
                    {'name':'Hawaii', 'abbrev':'HI'},
                    {'name':'Idaho', 'abbrev':'ID'},
                    {'name':'Illinois', 'abbrev':'IL'},
                    {'name':'Indiana', 'abbrev':'IN'},
                    {'name':'Iowa', 'abbrev':'IA'},
                    {'name':'Kansas', 'abbrev':'KS'},
                    {'name':'Kentucky', 'abbrev':'KY'},
                    {'name':'Louisiana', 'abbrev':'LA'},
                    {'name':'Maine', 'abbrev':'ME'},
                    {'name':'Maryland', 'abbrev':'MD'},
                    {'name':'Massachusetts', 'abbrev':'MA'},
                    {'name':'Michigan', 'abbrev':'MI'},
                    {'name':'Minnesota', 'abbrev':'MN'},
                    {'name':'Mississippi', 'abbrev':'MS'},
                    {'name':'Missouri', 'abbrev':'MO'},
                    {'name':'Montana', 'abbrev':'MT'},
                    {'name':'Nebraska', 'abbrev':'NE'},
                    {'name':'Nevada', 'abbrev':'NV'},
                    {'name':'New Hampshire', 'abbrev':'NH'},
                    {'name':'New Jersey', 'abbrev':'NJ'},
                    {'name':'New Mexico', 'abbrev':'NM'},
                    {'name':'New York', 'abbrev':'NY'},
                    {'name':'North Carolina', 'abbrev':'NC'},
                    {'name':'North Dakota', 'abbrev':'ND'},
                    {'name':'Ohio', 'abbrev':'OH'},
                    {'name':'Oklahoma', 'abbrev':'OK'},
                    {'name':'Oregon', 'abbrev':'OR'},
                    {'name':'Pennsylvania', 'abbrev':'PA'},
                    {'name':'Rhode Island', 'abbrev':'RI'},
                    {'name':'South Carolina', 'abbrev':'SC'},
                    {'name':'South Dakota', 'abbrev':'SD'},
                    {'name':'Tennessee', 'abbrev':'TN'},
                    {'name':'Texas', 'abbrev':'TX'},
                    {'name':'Utah', 'abbrev':'UT'},
                    {'name':'Vermont', 'abbrev':'VT'},
                    {'name':'Virginia', 'abbrev':'VA'},
                    {'name':'Washington', 'abbrev':'WA'},
                    {'name':'West Virginia', 'abbrev':'WV'},
                    {'name':'Wisconsin', 'abbrev':'WI'},
                    {'name':'Wyoming', 'abbrev':'WY'}
                ]
            },

            generatePhotoURLs : function(propData, limit){
                if (limit == null) limit = 50;
                if (propData.photos == null){
                    return ([0,1,2,3,4,5,6,7,8]).map(function() {
                        return app.data.domain + '/files/images/dummy-property-' + (Math.floor(Math.random() * 11) + 1) + '.jpg';
                    })
                    
                }
                var id = propData._id,
                    endings = propData.photos.endings;
                var noEndings = (typeof endings == 'undefined') ? true : false;
                if (noEndings){
                    console.log('No endings on property ' + id);
                }
                var photoNums = [];
                var i = 0;
                var photoCountLimit = Math.min(parseInt(propData.photos.uploaded_count || propData.photos.photo_count || 0), limit)
                while (i < photoCountLimit) {
                    photoNums.push(i++);
                }
                //console.log('photos: ' + i)
                return photoNums.map(function(photoSlideNumber, index, arr){
                    return (
                        app.data.property_photos_base_url + 
                        id + '-' + photoSlideNumber + 
                        '.' + (noEndings ? 'jpg' : endings["" + photoSlideNumber] || 'jpg')
                    );
                }.bind(this));
            }

        },
        
    },
    
    layout : {
        
        changed : function(){
            return null;
        }
        
    }
    
}
