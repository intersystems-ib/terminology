Class Terminology.Snomed.DTO.ConceptResult Extends Terminology.Snomed.DTO.Base
{

Property ConceptId As %String(%JSONFIELDNAME = "conceptId");

Property Active As %Integer(%JSONFIELDNAME = "active");

Property ModuleId As %String(%JSONFIELDNAME = "moduleId");

Property DefinitionStatusId As %String(%JSONFIELDNAME = "definitionStatusId");

Property EffectiveTime As %String(%JSONFIELDNAME = "effectiveTime");

Property PreferredTerm As %String(%JSONFIELDNAME = "preferredTerm");

Storage Default
{
<Data name="ConceptResultState">
<Subscript>"ConceptResult"</Subscript>
<Value name="1">
<Value>ConceptId</Value>
</Value>
<Value name="2">
<Value>Active</Value>
</Value>
<Value name="3">
<Value>ModuleId</Value>
</Value>
<Value name="4">
<Value>DefinitionStatusId</Value>
</Value>
<Value name="5">
<Value>EffectiveTime</Value>
</Value>
<Value name="6">
<Value>PreferredTerm</Value>
</Value>
</Data>
<State>ConceptResultState</State>
<Type>%Storage.Serial</Type>
}

}
