Class Terminology.Vector.DTO.SearchItem Extends Terminology.Vector.DTO.Base
{

Property SystemUri As %String(MAXLEN = 200);

Property ReleaseId As %String(MAXLEN = 100);

Property Code As %String(MAXLEN = 40);

Property Lang As %String(MAXLEN = 10);

Property Text As %String(MAXLEN = 4000);

Property Model As %String(MAXLEN = 200);

Property Score As %Double;

Storage Default
{
<Data name="SearchItemState">
<Subscript>"SearchItem"</Subscript>
<Value name="1">
<Value>SystemUri</Value>
</Value>
<Value name="2">
<Value>ReleaseId</Value>
</Value>
<Value name="3">
<Value>Code</Value>
</Value>
<Value name="4">
<Value>Lang</Value>
</Value>
<Value name="5">
<Value>Text</Value>
</Value>
<Value name="6">
<Value>Model</Value>
</Value>
<Value name="7">
<Value>Score</Value>
</Value>
</Data>
<State>SearchItemState</State>
<Type>%Storage.Serial</Type>
}

}
