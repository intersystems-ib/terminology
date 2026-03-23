Class Terminology.Production.Msg.SnomedRf2LoadResponse Extends Ens.Response
{

Property ReleaseId As %String;

Property FileName As %String(MAXLEN = 100);

Property Message As %String(MAXLEN = 100);

Storage Default
{
<Data name="SnomedRf2LoadResponseDefaultData">
<Subscript>"SnomedRf2LoadResponse"</Subscript>
<Value name="1">
<Value>ReleaseId</Value>
</Value>
<Value name="2">
<Value>FileName</Value>
</Value>
<Value name="3">
<Value>Message</Value>
</Value>
</Data>
<DefaultData>SnomedRf2LoadResponseDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
