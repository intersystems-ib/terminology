Class Terminology.Mapping.SnomedToIcd10 Extends %Persistent
{

Property ReleaseId As %String(MAXLEN = 64) [ Required ];

Property SourceConceptId As %BigInt [ Required ];

Property TargetCode As %String(MAXLEN = 20) [ Required ];

Property Equivalence As %String(MAXLEN = 50);

Property Rule As %String(MAXLEN = 2000);

Index PK On (ReleaseId, SourceConceptId, TargetCode) [ Unique ];

Index IXTarget On (ReleaseId, TargetCode);

Storage Default
{
<Data name="SnomedToIcd10DefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>ReleaseId</Value>
</Value>
<Value name="3">
<Value>SourceConceptId</Value>
</Value>
<Value name="4">
<Value>TargetCode</Value>
</Value>
<Value name="5">
<Value>Equivalence</Value>
</Value>
<Value name="6">
<Value>Rule</Value>
</Value>
</Data>
<DataLocation>^TerminologyC906.SnomedToIcd10D</DataLocation>
<DefaultData>SnomedToIcd10DefaultData</DefaultData>
<IdLocation>^TerminologyC906.SnomedToIcd10D</IdLocation>
<IndexLocation>^TerminologyC906.SnomedToIcd10I</IndexLocation>
<StreamLocation>^TerminologyC906.SnomedToIcd10S</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
