Class Terminology.Snomed.DTO.Icd10MappingResult Extends Terminology.Snomed.DTO.Base
{

Property Count As %Integer;

Property Items As list Of Terminology.Snomed.DTO.Icd10MappingItem;

Storage Default
{
<Data name="Icd10MappingResultState">
<Subscript>"Icd10MappingResult"</Subscript>
<Value name="1">
<Value>Count</Value>
</Value>
<Value name="2">
<Value>Items</Value>
</Value>
</Data>
<State>Icd10MappingResultState</State>
<Type>%Storage.Serial</Type>
}

}
