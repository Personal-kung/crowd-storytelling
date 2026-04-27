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

export interface Story {
  id: string;
  title: string;
  name: string;
  country: string;
  text_content: string;
  timestamp: any;
  contact: string;
  status: string;
  type: string;
  coverImage?: string;
  transcreated_content?: string;
  localizedCountry?: string | null;
  writingMode?: 'horizontal-tb' | 'vertical-rl';
  readingCadence?: number;
  dwellTime?: number;
}

export interface EnvironmentTheme {
  primaryColor: string;
  secondaryColor: string;
  ambientAnimation: 'blossoms' | 'sand' | 'rain' | 'leaves' | 'none';
}
