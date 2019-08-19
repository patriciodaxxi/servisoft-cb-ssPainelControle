@echo off
c:
cd \
cd C:\Program Files (x86)
cd Firebird\Firebird_2_5
cd bin
@echo on
GBak -g -l -b 10.1.1.101:D:\Fontes\$Servisoft\Bases\SSFacil\SSFacil.FDB d:\SSFacil.fbk -user sysdba -pas masterkey
