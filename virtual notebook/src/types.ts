export type Nationality = 'Japan' | 'Egypt' | 'France' | 'Brazil' | 'Unknown';

export interface Author {
  name: string;
  nationality: Nationality;
  flag: string;
  bio: string;
}

export interface StoryPage {
  content: string;
  image?: string;
}

export interface CoverImage {
  path: string;
  generatedAt?: any;
}


export interface StoryTranslation {
  localizedCountry?: string;

  // Existing transcreation format
  transcreatedTitle?: string;
  transcreated_content?: string;

  // Firebase translation format
  translatedTitle?: string;
  translatedContent?: string;

  writingMode?: 'horizontal-tb' | 'vertical-rl';
}


export interface Story {
  id: string;

  title: string;
  name: string;
  country: string;

  text_content: string;

  sourceLanguage?: string;

  timestamp: any;

  contact?: string;

  status: string;

  type?: string;


  // Firebase:
  // {
  //   path:"covers/example.png",
  //   generatedAt:Timestamp
  // }
  //
  // Runtime:
  // "https://firebasestorage.googleapis.com/..."
  coverImage?: CoverImage | string;


  translations?: {
    [languageCode: string]: StoryTranslation;
  };


  // Runtime fields
  // Added after language/image processing

  localizedCountry?: string;

  transcreated_content?: string;

  writingMode?: 'horizontal-tb' | 'vertical-rl';

  originalTitle?: string;
}

export interface EnvironmentTheme {
  primaryColor: string;
  secondaryColor: string;
  ambientAnimation: 'blossoms' | 'sand' | 'rain' | 'leaves' | 'none';
}
