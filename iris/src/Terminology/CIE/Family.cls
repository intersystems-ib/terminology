Class Terminology.CIE.Family Extends (%Persistent, %Populate, %JSON.Adaptor)
{

Property ReleaseId As %String(MAXLEN = 64) [ Required ];

Property Version As %Integer [ Required ];

Property CodeType As %String(MAXLEN = 32) [ Required ];

// DIAGNOSIS / PROCEDURE

Property FamilyCode As %String(MAXLEN = 32) [ Required ];

Property Description As %String(MAXLEN = 1000);

Property DescriptionNorm As %String(MAXLEN = 1000);

Property ChapterCode As %String(MAXLEN = 32);

Property RangeStart As %String(MAXLEN = 16);

Property RangeEnd As %String(MAXLEN = 16);

Index PK On (ReleaseId, Version, CodeType, FamilyCode) [ Unique ];

Index IXChapter On (ReleaseId, Version, CodeType, ChapterCode);

Index IXFamilyDescriptionNorm On (DescriptionNorm) As %iFind.Index.Basic(INDEXOPTION = 0, LANGUAGE = "es");

Storage Default
{
<Data name="FamilyDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>ReleaseId</Value>
</Value>
<Value name="3">
<Value>Version</Value>
</Value>
<Value name="4">
<Value>CodeType</Value>
</Value>
<Value name="5">
<Value>FamilyCode</Value>
</Value>
<Value name="6">
<Value>Description</Value>
</Value>
<Value name="7">
<Value>DescriptionNorm</Value>
</Value>
<Value name="8">
<Value>ChapterCode</Value>
</Value>
<Value name="9">
<Value>RangeStart</Value>
</Value>
<Value name="10">
<Value>RangeEnd</Value>
</Value>
</Data>
<DataLocation>^Terminology.CIE.FamilyD</DataLocation>
<DefaultData>FamilyDefaultData</DefaultData>
<IdLocation>^Terminology.CIE.FamilyD</IdLocation>
<IndexLocation>^Terminology.CIE.FamilyI</IndexLocation>
<StreamLocation>^Terminology.CIE.FamilyS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
