Flash Videoplayer
=====================
AS ideAS Engineering, BILD GmbH & Co. KG

Axel-Springer-Straße 65

10888 Berlin

Igor Savchenko


### Installation:
Außer standard [Flex Apache SDK](http://flex.apache.org/installer.html) ist [HDCore-v2.11.3](http://mediapm.edgesuite.net/akamai-osmf-plugins/samples/index.html) notwendig. In SDK soll OSMF.lib dabei sein.


### Flash Probleme und Lösungen in IntelliJ:
  +  Preferences > Compiler > ActionScript Compiler:   Compile with mxmlc/compc
  +  In Run/Debug Configuration:   Launch with Chrome (!!! Chrome soll debugger Player haben und vorinstallierten "Pepper"-Player ausschalten)
  +  In Run/Debug Configuration:  Use debugger from SDK: Flex Apache