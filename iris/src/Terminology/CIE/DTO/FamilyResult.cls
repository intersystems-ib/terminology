Class Terminology.CIE.DTO.FamilyResult Extends Terminology.CIE.DTO.Base
{

Property Count As %Integer;

Property Items As list Of Terminology.CIE.DTO.FamilyItem;

Storage Default
{
<Data name="FamilyResultState">
<Subscript>"FamilyResult"</Subscript>
<Value name="1">
<Value>Count</Value>
</Value>
<Value name="2">
<Value>Items</Value>
</Value>
</Data>
<State>FamilyResultState</State>
<Type>%Storage.Serial</Type>
}

}
