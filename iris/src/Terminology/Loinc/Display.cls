Class Terminology.Loinc.Display Extends %Persistent
{

Property ReleaseId As %String(MAXLEN = 100) [ Required ];

Property LoincNum As %String(MAXLEN = 20) [ Required ];

Property Lang As %String(MAXLEN = 10) [ Required ];

Property DisplayType As %String(MAXLEN = 50) [ Required ];

Property Display As %String(MAXLEN = 4000) [ Required ];

Property DisplayNorm As %String(MAXLEN = 4000);

Property RankOrder As %Integer;

Index PK On (ReleaseId, LoincNum, Lang, DisplayType) [ Unique ];

Index IXDisplayFind On DisplayNorm [ Type = bitslice ];

Index IXLoincNum On (ReleaseId, LoincNum);

Index IXDisplayNormFind On (DisplayNorm) As %iFind.Index.Basic(INDEXOPTION = 0, LANGUAGE = "es");

Storage Default
{
<Data name="DisplayDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>ReleaseId</Value>
</Value>
<Value name="3">
<Value>LoincNum</Value>
</Value>
<Value name="4">
<Value>Lang</Value>
</Value>
<Value name="5">
<Value>DisplayType</Value>
</Value>
<Value name="6">
<Value>Display</Value>
</Value>
<Value name="7">
<Value>DisplayNorm</Value>
</Value>
<Value name="8">
<Value>RankOrder</Value>
</Value>
</Data>
<DataLocation>^Terminology.Loinc.DisplayD</DataLocation>
<DefaultData>DisplayDefaultData</DefaultData>
<IdLocation>^Terminology.Loinc.DisplayD</IdLocation>
<IndexLocation>^Terminology.Loinc.DisplayI</IndexLocation>
<StreamLocation>^Terminology.Loinc.DisplayS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
