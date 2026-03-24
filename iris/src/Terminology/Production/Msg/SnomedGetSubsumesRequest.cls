Class Terminology.Production.Msg.SnomedGetSubsumesRequest Extends Ens.Request
{

Property ReleaseId As %String;

Property View As %String;

Property CodeA As %String;

Property CodeB As %String;

Storage Default
{
<Data name="SnomedGetSubsumesRequestDefaultData">
<Subscript>"SnomedGetSubsumesRequest"</Subscript>
<Value name="1">
<Value>ReleaseId</Value>
</Value>
<Value name="2">
<Value>View</Value>
</Value>
<Value name="3">
<Value>CodeA</Value>
</Value>
<Value name="4">
<Value>CodeB</Value>
</Value>
</Data>
<DefaultData>SnomedGetSubsumesRequestDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
