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

export interface StoryTranslation {
  localizedCountry?: string;
  transcreatedTitle?: string;
  transcreated_content?: string;
  writingMode?: 'horizontal-tb' | 'vertical-rl';
}

export interface Story {
  id: string;
  title: string;
  name: string;
  country: string;
  text_content: string;
  timestamp: any;
  contact?: string;
  status: string;
  type: string;

  coverImage?: string;
  translations?: { [languageCode: string]: StoryTranslation; };

  // Runtime fields
  // These are not stored in Firestore,
  // they are added after language resolution
  localizedCountry?: string;
  transcreated_content?: string;
  writingMode?: 'horizontal-tb' | 'vertical-rl';
}

export interface EnvironmentTheme {
  primaryColor: string;
  secondaryColor: string;
  ambientAnimation: 'blossoms' | 'sand' | 'rain' | 'leaves' | 'none';
}
