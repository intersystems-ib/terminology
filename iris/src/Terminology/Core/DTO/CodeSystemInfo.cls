/// Neutral code system metadata returned to API layers.
Class Terminology.Core.DTO.CodeSystemInfo Extends Terminology.Core.DTO.Base
{

Property Id As %String(%JSONFIELDNAME = "id");

Property Url As %String(%JSONFIELDNAME = "url");

Property Version As %String(%JSONFIELDNAME = "version");

Property Name As %String(%JSONFIELDNAME = "name");

Property Title As %String(%JSONFIELDNAME = "title");

Property Status As %String(%JSONFIELDNAME = "status");

Property Content As %String(%JSONFIELDNAME = "content");

Property Description As %String(%JSONFIELDNAME = "description");

Property DefaultLang As %String(%JSONFIELDNAME = "defaultLang");

Property DefaultDialect As %String(%JSONFIELDNAME = "defaultDialect");

Storage Default
{
<Data name="CodeSystemInfoState">
<Subscript>"CodeSystemInfo"</Subscript>
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
<Value>Content</Value>
</Value>
<Value name="8">
<Value>Description</Value>
</Value>
<Value name="9">
<Value>DefaultLang</Value>
</Value>
<Value name="10">
<Value>DefaultDialect</Value>
</Value>
</Data>
<State>CodeSystemInfoState</State>
<Type>%Storage.Serial</Type>
}

}
