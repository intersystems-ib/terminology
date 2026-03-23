Class Terminology.Vector.TermEmbedding Extends %Persistent [ DdlAllowed ]
{

Parameter SQLTableName = "VectorTermEmbedding";

Property ReleaseId As %String(MAXLEN = 64) [ Required ];

Property SystemUri As %String(MAXLEN = 200) [ Required ];

Property Code As %String(MAXLEN = 40) [ Required ];

Property Lang As %String(MAXLEN = 10);

Property Text As %String(MAXLEN = 2000) [ Required ];

Property Model As %String(MAXLEN = 100);

Property Embedding As %Library.Vector(DATATYPE = "DECIMAL", LEN = 768);

Index PK On (ReleaseId, SystemUri, Code, Lang, Text) [ Unique ];

Index IXCode On (ReleaseId, SystemUri, Code);

Index IXEmbedding On (Embedding) As %SQL.Index.HNSW(Distance = "DotProduct") [ SqlName = IXEmbedding, Type = index ];

Storage Default
{
<Data name="TermEmbeddingDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>ReleaseId</Value>
</Value>
<Value name="3">
<Value>SystemUri</Value>
</Value>
<Value name="4">
<Value>Code</Value>
</Value>
<Value name="5">
<Value>Lang</Value>
</Value>
<Value name="6">
<Value>Text</Value>
</Value>
<Value name="7">
<Value>Model</Value>
</Value>
<Value name="8">
<Value>Embedding</Value>
</Value>
</Data>
<DataLocation>^Terminology.VeCE.TermEmbeddingD</DataLocation>
<DefaultData>TermEmbeddingDefaultData</DefaultData>
<IdLocation>^Terminology.VeCE.TermEmbeddingD</IdLocation>
<IndexLocation>^Terminology.VeCE.TermEmbeddingI</IndexLocation>
<StreamLocation>^Terminology.VeCE.TermEmbeddingS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
