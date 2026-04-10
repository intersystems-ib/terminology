Class Terminology.CIE.Chapter Extends (%Persistent, %Populate, %JSON.Adaptor)
{

Property ReleaseId As %String(MAXLEN = 64) [ Required ];

Property Version As %Integer [ Required ];

Property CodeType As %String(MAXLEN = 32) [ Required ];

// DIAGNOSIS / PROCEDURE

Property ChapterCode As %String(MAXLEN = 32) [ Required ];

Property Description As %String(MAXLEN = 1000);

Property RangeText As %String(MAXLEN = 128);

Property DescriptionNorm As %String(MAXLEN = 1000);

Index PK On (ReleaseId, Version, CodeType, ChapterCode) [ Unique ];

Index IXChapterDescriptionNorm On (DescriptionNorm) As %iFind.Index.Basic(INDEXOPTION = 0, LANGUAGE = "es");

Storage Default
{
<Data name="ChapterDefaultData">
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
<Value>ChapterCode</Value>
</Value>
<Value name="6">
<Value>Description</Value>
</Value>
<Value name="7">
<Value>RangeText</Value>
</Value>
<Value name="8">
<Value>DescriptionNorm</Value>
</Value>
</Data>
<DataLocation>^Terminology.CIE.ChapterD</DataLocation>
<DefaultData>ChapterDefaultData</DefaultData>
<IdLocation>^Terminology.CIE.ChapterD</IdLocation>
<IndexLocation>^Terminology.CIE.ChapterI</IndexLocation>
<StreamLocation>^Terminology.CIE.ChapterS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
