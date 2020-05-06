require './Extreml.rb'

ric = './SdIRiceviFile_v1.0.wsdl'
xsd = './RicezioneTypes_v1.0.xsd'
xml = './IT02663950984_7FSk5.xml'
tst = 'test.wsdl'
test = Extreml.new(xml)

# pp test.document.tree
pp test.document.FatturaElettronica.FatturaElettronicaBody.DatiBeniServizi.DettaglioLinee[6].__tree
pp test.document.FatturaElettronica.FatturaElettronicaHeader.__tree
puts test.document.FatturaElettronica.FatturaElettronicaHeader.TerzoIntermediarioOSoggettoEmittente.DatiAnagrafici.Anagrafica.Denominazione.to_s
