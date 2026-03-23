Class Terminology.Core.CodeSystem Extends %Persistent
{

Property SystemUri As %String(MAXLEN = 200) [ Required ];

Property Name As %String(MAXLEN = 100) [ Required ];

Property DefaultLang As %String(MAXLEN = 10);

Property DefaultDialect As %String(MAXLEN = 20);

Property Notes As %String(MAXLEN = 32000);

Index PK On SystemUri [ Unique ];

Storage Default
{
<Data name="CodeSystemDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>SystemUri</Value>
</Value>
<Value name="3">
<Value>Name</Value>
</Value>
<Value name="4">
<Value>DefaultLang</Value>
</Value>
<Value name="5">
<Value>DefaultDialect</Value>
</Value>
<Value name="6">
<Value>Notes</Value>
</Value>
</Data>
<DataLocation>^Terminology.Core.CodeSystemD</DataLocation>
<DefaultData>CodeSystemDefaultData</DefaultData>
<IdLocation>^Terminology.Core.CodeSystemD</IdLocation>
<IndexLocation>^Terminology.Core.CodeSystemI</IndexLocation>
<StreamLocation>^Terminology.Core.CodeSystemS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
