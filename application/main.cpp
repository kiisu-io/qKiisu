#include "application.h"

#include <QSettings>

int main(int argc, char *argv[])
{
    QSettings::setDefaultFormat(QSettings::IniFormat);

    QCoreApplication::setApplicationName(APP_NAME);
    QCoreApplication::setApplicationVersion(APP_VERSION);
    QCoreApplication::setOrganizationName(QStringLiteral("RainWalker"));
    QCoreApplication::setOrganizationDomain(QStringLiteral("kiisu.io"));

#if QT_VERSION < 0x060000
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif

    QGuiApplication::setHighDpiScaleFactorRoundingPolicy(Qt::HighDpiScaleFactorRoundingPolicy::RoundPreferFloor);

    Application app(argc, argv);
    return app.exec();
}
