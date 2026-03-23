Class Terminology.Production.Msg.SnomedGetChildrenRequest Extends Ens.Request
{

Property ConceptId As %String;

Property ReleaseId As %String;

Property View As %String;

Property Lang As %String;

Property Dialect As %String;

Storage Default
{
<Data name="SnomedGetChildrenRequestDefaultData">
<Subscript>"SnomedGetChildrenRequest"</Subscript>
<Value name="1">
<Value>ConceptId</Value>
</Value>
<Value name="2">
<Value>ReleaseId</Value>
</Value>
<Value name="3">
<Value>View</Value>
</Value>
<Value name="4">
<Value>Lang</Value>
</Value>
<Value name="5">
<Value>Dialect</Value>
</Value>
</Data>
<DefaultData>SnomedGetChildrenRequestDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
