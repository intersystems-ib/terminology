Class Terminology.Snomed.LanguageRefSetConfig Extends %Persistent
{

Property ReleaseId As %String(MAXLEN = 64) [ Required ];

Property Lang As %String(MAXLEN = 10) [ Required ];

// "es"

Property Dialect As %String(MAXLEN = 20) [ Required ];

// "es-ES" o "default"

Property RefsetId As %BigInt [ Required ];

Index PK On (ReleaseId, Lang, Dialect) [ Unique ];

Index IXRefset On (ReleaseId, RefsetId);

Storage Default
{
<Data name="LanguageRefSetConfigDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>ReleaseId</Value>
</Value>
<Value name="3">
<Value>Lang</Value>
</Value>
<Value name="4">
<Value>Dialect</Value>
</Value>
<Value name="5">
<Value>RefsetId</Value>
</Value>
</Data>
<DataLocation>^Terminolog6D3E.LanguageRef8E91D</DataLocation>
<DefaultData>LanguageRefSetConfigDefaultData</DefaultData>
<IdLocation>^Terminolog6D3E.LanguageRef8E91D</IdLocation>
<IndexLocation>^Terminolog6D3E.LanguageRef8E91I</IndexLocation>
<StreamLocation>^Terminolog6D3E.LanguageRef8E91S</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
