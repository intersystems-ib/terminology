Class Terminology.Vector.DTO.CrosswalkResult Extends Terminology.Vector.DTO.Base
{

Property Count As %Integer;

Property Items As list Of Terminology.Vector.DTO.CrosswalkItem;

Storage Default
{
<Data name="CrosswalkResultState">
<Subscript>"CrosswalkResult"</Subscript>
<Value name="1">
<Value>Count</Value>
</Value>
<Value name="2">
<Value>Items</Value>
</Value>
</Data>
<State>CrosswalkResultState</State>
<Type>%Storage.Serial</Type>
}

}
