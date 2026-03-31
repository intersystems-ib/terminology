/// Neutral value set metadata returned to API layers.
Class Terminology.Core.DTO.ValueSetInfo Extends Terminology.Core.DTO.Base
{

Property Id As %String(%JSONFIELDNAME = "id");

Property Url As %String(%JSONFIELDNAME = "url");

Property Version As %String(%JSONFIELDNAME = "version");

Property Name As %String(%JSONFIELDNAME = "name");

Property Title As %String(%JSONFIELDNAME = "title");

Property Status As %String(%JSONFIELDNAME = "status");

Property Description As %String(%JSONFIELDNAME = "description");

Storage Default
{
<Data name="ValueSetInfoState">
<Subscript>"ValueSetInfo"</Subscript>
<Value name="1">
<Value>Id</Value>
</Value>
<Value name="2">
<Value>Url</Value>
</Value>
<Value name="3">
<Value>Version</Value>
</Value>
<Value name="4">
<Value>Name</Value>
</Value>
<Value name="5">
<Value>Title</Value>
</Value>
<Value name="6">
<Value>Status</Value>
</Value>
<Value name="7">
<Value>Description</Value>
</Value>
</Data>
<State>ValueSetInfoState</State>
<Type>%Storage.Serial</Type>
}

}
