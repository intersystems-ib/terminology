Class Terminology.Snomed.PreferredTermStage Extends %Persistent
{

Property ReleaseId As %String(MAXLEN = 100) [ Required ];

Property Lang As %String(MAXLEN = 10) [ Required ];

Property Dialect As %String(MAXLEN = 20) [ Required ];

Property ConceptId As %BigInt [ Required ];

Property DescriptionId As %BigInt [ Required ];

Property Term As %String(MAXLEN = 2000) [ Required ];

Property TermNorm As %String(MAXLEN = 2000);

Index PK On (ReleaseId, Lang, Dialect, ConceptId) [ IdKey, Unique ];

Index IXDescription On (ReleaseId, DescriptionId);

Index IXScope On (ReleaseId, Lang, Dialect);

Storage Default
{
<Data name="PreferredTermStageDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>DescriptionId</Value>
</Value>
<Value name="3">
<Value>Term</Value>
</Value>
<Value name="4">
<Value>TermNorm</Value>
</Value>
</Data>
<DataLocation>^Terminolog6D3E.PreferredTeA526D</DataLocation>
<DefaultData>PreferredTermStageDefaultData</DefaultData>
<IdLocation>^Terminolog6D3E.PreferredTeA526D</IdLocation>
<IndexLocation>^Terminolog6D3E.PreferredTeA526I</IndexLocation>
<StreamLocation>^Terminolog6D3E.PreferredTeA526S</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
