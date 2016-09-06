#include <QtGlobal>
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QtDebug>

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    QPM_INIT(engine)
    engine.load(QUrl(QLatin1String("qrc:/main.qml")));

    qDebug() << "foo";

    return app.exec();
}
