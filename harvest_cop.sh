
#!/bin/sh

cd docs

xsltproc  ../ese2solr.xsl "http://www.kb.dk/cop/oai/?verb=ListRecords&set=oai:kb.dk:maps:kortsa:2012:jul:kortatlas&metadataPrefix=ese" | xmllint --format -  > kortatlas.xml 
xsltproc  ../ese2solr.xsl "http://www.kb.dk/cop/oai/?verb=ListRecords&set=oai:kb.dk:pamphlets:dasmaa:2008:feb:partiprogrammer&metadataPrefix=ese"  | xmllint --format -  > partiprogrammer.xml 
xsltproc  ../ese2solr.xsl "http://www.kb.dk/cop/oai/?verb=ListRecords&set=oai:kb.dk:manus:judsam:2009:sep:dsh&metadataPrefix=ese"  | xmllint --format -  > dsh.xml

