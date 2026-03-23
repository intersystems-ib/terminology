Class Terminology.Snomed.Description Extends %Persistent
{

Property ReleaseId As %String(MAXLEN = 64) [ Required ];

Property DescriptionId As %BigInt [ Required ];

Property ConceptId As %BigInt [ Required ];

Property Active As %Integer [ Required ];

Property TypeId As %BigInt [ Required ];

Property Lang As %String(MAXLEN = 10) [ Required ];

Property Term As %String(MAXLEN = 2000) [ Required ];

Property CaseSignificanceId As %BigInt;

Property EffectiveTime As %Date;

Index PK On (ReleaseId, DescriptionId) [ Unique ];

Index IXConcept On (ReleaseId, ConceptId);

Index IXLangActive On (ReleaseId, Lang, Active);

Index IXPreferredBuild On (ReleaseId, Lang, Active, TypeId, ConceptId, DescriptionId);

Storage Default
{
<Data name="DescriptionDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>ReleaseId</Value>
</Value>
<Value name="3">
<Value>DescriptionId</Value>
</Value>
<Value name="4">
<Value>ConceptId</Value>
</Value>
<Value name="5">
<Value>Active</Value>
</Value>
<Value name="6">
<Value>TypeId</Value>
</Value>
<Value name="7">
<Value>Lang</Value>
</Value>
<Value name="8">
<Value>Term</Value>
</Value>
<Value name="9">
<Value>CaseSignificanceId</Value>
</Value>
<Value name="10">
<Value>EffectiveTime</Value>
</Value>
</Data>
<DataLocation>^Terminology.Sn6D3E.DescriptionD</DataLocation>
<DefaultData>DescriptionDefaultData</DefaultData>
<IdLocation>^Terminology.Sn6D3E.DescriptionD</IdLocation>
<IndexLocation>^Terminology.Sn6D3E.DescriptionI</IndexLocation>
<StreamLocation>^Terminology.Sn6D3E.DescriptionS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
