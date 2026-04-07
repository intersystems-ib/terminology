Class Terminology.Loinc.DTO.DisplayItem Extends Terminology.Loinc.DTO.Base
{

Property LoincNum As %String;

Property Lang As %String;

Property DisplayType As %String;

Property Display As %String(MAXLEN = 4000);

Property RankOrder As %Integer;

Storage Default
{
<Data name="DisplayItemState">
<Subscript>"DisplayItem"</Subscript>
<Value name="1">
<Value>LoincNum</Value>
</Value>
<Value name="2">
<Value>Lang</Value>
</Value>
<Value name="3">
<Value>DisplayType</Value>
</Value>
<Value name="4">
<Value>Display</Value>
</Value>
<Value name="5">
<Value>RankOrder</Value>
</Value>
</Data>
<State>DisplayItemState</State>
<Type>%Storage.Serial</Type>
}

}
