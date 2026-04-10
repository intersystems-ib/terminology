Class Terminology.Production.Msg.SnomedGetDescendantsRequest Extends Terminology.Production.Msg.BaseRequest
{

Property ConceptId As %String;

Property ReleaseId As %String;

Property View As %String;

Property Lang As %String;

Property Dialect As %String;

Property Limit As %Integer;

Property Offset As %Integer;

Storage Default
{
<Data name="SnomedGetDescendantsRequestDefaultData">
<Subscript>"SnomedGetDescendantsRequest"</Subscript>
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
<Value name="6">
<Value>Limit</Value>
</Value>
<Value name="7">
<Value>Offset</Value>
</Value>
</Data>
<DefaultData>SnomedGetDescendantsRequestDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
