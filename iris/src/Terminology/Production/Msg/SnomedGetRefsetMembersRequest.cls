Class Terminology.Production.Msg.SnomedGetRefsetMembersRequest Extends Terminology.Production.Msg.BaseRequest
{

Property ReleaseId As %String;

Property RefsetId As %String;

Property Lang As %String;

Property Dialect As %String;

Property Limit As %Integer;

Property Offset As %Integer;

Storage Default
{
<Data name="SnomedGetRefsetMembersRequestDefaultData">
<Subscript>"SnomedGetRefsetMembersRequest"</Subscript>
<Value name="1">
<Value>ReleaseId</Value>
</Value>
<Value name="2">
<Value>RefsetId</Value>
</Value>
<Value name="3">
<Value>Lang</Value>
</Value>
<Value name="4">
<Value>Dialect</Value>
</Value>
<Value name="5">
<Value>Limit</Value>
</Value>
<Value name="6">
<Value>Offset</Value>
</Value>
</Data>
<DefaultData>SnomedGetRefsetMembersRequestDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
