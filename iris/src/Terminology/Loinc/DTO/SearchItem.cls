Class Terminology.Loinc.DTO.SearchItem Extends Terminology.Loinc.DTO.Base
{

Property LoincNum As %String;

Property Display As %String(MAXLEN = 4000);

Property DisplayType As %String;

Storage Default
{
<Data name="SearchItemState">
<Subscript>"SearchItem"</Subscript>
<Value name="1">
<Value>LoincNum</Value>
</Value>
<Value name="2">
<Value>Display</Value>
</Value>
<Value name="3">
<Value>DisplayType</Value>
</Value>
</Data>
<State>SearchItemState</State>
<Type>%Storage.Serial</Type>
}

}
