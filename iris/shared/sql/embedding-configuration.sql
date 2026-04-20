USE DATABASE "TERMINOLOGY"
GO
INSERT INTO %Embedding.Config (Name, Configuration, EmbeddingClass, Description)
  VALUES ('sentence-transformers-config',
          '{"modelName":"FremyCompany/BioLORD-2023-M",
            "hfCachePath":"/tmp/hfCache",
            "maxTokens": 768,
            "checkTokenCount": true}',
          '%Embedding.SentenceTransformers',
          'BioLord-2023-M model from Hugging Face, optimized for biomedical text.')
GO
CREATE TABLE IF NOT EXISTS Terminology_Vector.TermEmbedding (
    ReleaseId VARCHAR(100) NOT NULL,
    Code VARCHAR(40) NOT NULL,
    Lang VARCHAR(10),
    Description VARCHAR(2000) NOT NULL,
    DescriptionEmbedding EMBEDDING ('sentence-transformers-config', 'Description')
)
GO
CREATE UNIQUE INDEX TermEmbedding_Unique ON TABLE Terminology_Vector.TermEmbedding (TermId, Terminology, Code, Lang)
GO
CREATE INDEX TermEmbedding_Code ON TABLE Terminology_Vector.TermEmbedding (TermId, Terminology)
GO
CREATE INDEX HNSWIndexTerm ON TABLE Terminology_Vector.TermEmbedding (DescriptionEmbedding)
  AS HNSW(M=24, Distance='DotProduct')
GO