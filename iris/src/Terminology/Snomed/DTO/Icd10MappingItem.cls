Class Terminology.Snomed.DTO.Icd10MappingItem Extends Terminology.Snomed.DTO.Base
{

Property SourceConceptId As %String;

Property TargetCode As %String;

Property Equivalence As %String;

Property Rule As %String;

Storage Default
{
<Data name="Icd10MappingItemState">
<Subscript>"Icd10MappingItem"</Subscript>
<Value name="1">
<Value>SourceConceptId</Value>
</Value>
<Value name="2">
<Value>TargetCode</Value>
</Value>
<Value name="3">
<Value>Equivalence</Value>
</Value>
<Value name="4">
<Value>Rule</Value>
</Value>
</Data>
<State>Icd10MappingItemState</State>
<Type>%Storage.Serial</Type>
}

}
