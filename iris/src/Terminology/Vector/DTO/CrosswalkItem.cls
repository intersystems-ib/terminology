Class Terminology.Vector.DTO.CrosswalkItem Extends Terminology.Vector.DTO.Base
{

Property SourceText As %String(MAXLEN = 4000);

Property SystemUri As %String(MAXLEN = 200);

Property ReleaseId As %String(MAXLEN = 100);

Property Code As %String(MAXLEN = 40);

Property Lang As %String(MAXLEN = 10);

Property Text As %String(MAXLEN = 4000);

Property Model As %String(MAXLEN = 200);

Property Score As %Double;

Storage Default
{
<Data name="CrosswalkItemState">
<Subscript>"CrosswalkItem"</Subscript>
<Value name="1">
<Value>SourceText</Value>
</Value>
<Value name="2">
<Value>SystemUri</Value>
</Value>
<Value name="3">
<Value>ReleaseId</Value>
</Value>
<Value name="4">
<Value>Code</Value>
</Value>
<Value name="5">
<Value>Lang</Value>
</Value>
<Value name="6">
<Value>Text</Value>
</Value>
<Value name="7">
<Value>Model</Value>
</Value>
<Value name="8">
<Value>Score</Value>
</Value>
</Data>
<State>CrosswalkItemState</State>
<Type>%Storage.Serial</Type>
}

}
