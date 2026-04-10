Class Terminology.Production.Msg.SnomedRf2LoadRequest Extends Terminology.Production.Msg.BaseRequest
{

Property FileName As %String(MAXLEN = 200);

Property Directory As %String(MAXLEN = 200);

Property ReleaseId As %String;

Property SystemUri As %String(MAXLEN = 200);

Property EffectiveDate As %String;

Property SetActive As %Boolean;

Storage Default
{
<Data name="SnomedRf2LoadRequestDefaultData">
<Subscript>"SnomedRf2LoadRequest"</Subscript>
<Value name="1">
<Value>FileName</Value>
</Value>
<Value name="2">
<Value>Directory</Value>
</Value>
<Value name="3">
<Value>ReleaseId</Value>
</Value>
<Value name="4">
<Value>SystemUri</Value>
</Value>
<Value name="5">
<Value>EffectiveDate</Value>
</Value>
<Value name="6">
<Value>SetActive</Value>
</Value>
</Data>
<DefaultData>SnomedRf2LoadRequestDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
