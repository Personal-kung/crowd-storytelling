import { useState, useEffect, useMemo } from 'react';
import Notebook from './components/Notebook';
import { Story } from './types';
import { getApprovedStories, getApprovedStoryById } from './services/storyService';
import { clsx, type ClassValue } from 'clsx';
import { twMerge } from 'tailwind-merge';
import { getUserLanguage } from './services/languageService';

function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

function getSharedStoryIdFromUrl(): string | null {
  const path = window.location.pathname;
  const match = path.match(/^\/story\/([^/]+)/);
  if (match && match[1]) {
    return match[1];
  }
  return null;
}

export default function App() {
  const [stories, setStories] = useState<Story[]>([]);
  const [sharedStory, setSharedStory] = useState<Story | null>(null);
  const [currentPage, setCurrentPage] = useState(0);
  const [isOpen, setIsOpen] = useState(false);
  const [theme, setTheme] = useState<'light' | 'dark'>('light');
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [userLanguage, setUserLanguage] = useState("en");

  const [isMobile, setIsMobile] = useState(false);

  useEffect(() => {
    const checkViewport = () => {
      setIsMobile(window.innerWidth < 768);
    };
    checkViewport();
    window.addEventListener('resize', checkViewport);
    return () => window.removeEventListener('resize', checkViewport);
  }, []);

  useEffect(() => {
    setUserLanguage(
      getUserLanguage()
    );
  }, []);

  // Calculate global page structure:
  // Default URL: [Intro, ToC, Story0, Story1, ...]
  // Shared URL Desktop (!isMobile): [SharedStory(0), Blank(1), Intro(2), ToC(3), Story1(4), ...]
  // Shared URL Mobile (isMobile): [SharedStory(0), Intro(1), ToC(2), Story1(3), ...]
  const globalPages = useMemo(() => {
    if (!stories.length) return [];

    if (sharedStory) {
      if (!isMobile) {
        // Desktop
        const pages: any[] = [
          {
            type: 'story',
            storyIndex: 0,
            isCover: true
          },
          { type: 'blank' },
          { type: 'intro' },
          { type: 'toc' }
        ];
        for (let sIdx = 1; sIdx < stories.length; sIdx++) {
          pages.push({
            type: 'story',
            storyIndex: sIdx,
            isCover: true
          });
        }
        return pages;
      } else {
        // Mobile
        const pages: any[] = [
          {
            type: 'story',
            storyIndex: 0,
            isCover: true
          },
          { type: 'intro' },
          { type: 'toc' }
        ];
        for (let sIdx = 1; sIdx < stories.length; sIdx++) {
          pages.push({
            type: 'story',
            storyIndex: sIdx,
            isCover: true
          });
        }
        return pages;
      }
    } else {
      const pages: any[] = [
        { type: 'intro' },
        { type: 'toc' }
      ];
      stories.forEach((_, sIdx) => {
        pages.push({
          type: 'story',
          storyIndex: sIdx,
          isCover: true
        });
      });
      return pages;
    }
  }, [stories, sharedStory, isMobile]);

  useEffect(() => {
    async function loadStories() {
      try {
        const sharedId = getSharedStoryIdFromUrl();
        let sharedDoc: Story | null = null;
        if (sharedId) {
          sharedDoc = await getApprovedStoryById(sharedId);
          if (sharedDoc) {
            setSharedStory(sharedDoc);
          }
        }

        const fetchedStories = await getApprovedStories();
        if (sharedDoc) {
          const remaining = fetchedStories.filter(s => s.id !== sharedDoc!.id);
          setStories([sharedDoc, ...remaining]);
        } else {
          setStories(fetchedStories);
        }
      } catch (err) {
        console.error(
          "Story loading error:",
          err
        );
        setError(
          "Failed to fetch the vessel's records."
        );
      } finally {
        setLoading(false);
      }
    }
    loadStories();
  }, []);

  const toggleTheme = () => {
    setTheme(prev => {
      const next = prev === 'light' ? 'dark' : 'light';
      if (next === 'dark') document.documentElement.classList.add('dark');
      else document.documentElement.classList.remove('dark');
      return next;
    });
  };

  const localizedStories = useMemo(() => {
    return stories.map(story => ({
      ...story,
      title: story.title,
      text_content: story.text_content,
      writingMode: story.writingMode,
      localizedCountry: story.localizedCountry,
      translations: story.translations
    }));
  }, [
    stories,
    userLanguage
  ]);

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-parchment dark:bg-parchment-dark">
        <div className="animate-pulse text-black dark:text-stone-50 font-serif text-2xl italic">Consulting the Scribe's Archive...</div>
      </div>
    );
  }

  return (
    <div className={cn(
      "min-h-screen transition-colors duration-1000",
      theme === 'dark' ? 'bg-[#0F0F10]' : 'bg-[#E5E0D0]'
    )}>
      <main className="relative flex items-center justify-center min-h-screen p-4 md:p-8">
        <Notebook
          stories={localizedStories}
          sharedStory={sharedStory}
          globalPages={globalPages}
          theme={theme}
          onThemeToggle={toggleTheme}
          currentPage={currentPage}
          setCurrentPage={setCurrentPage}
          isOpen={isOpen}
          setIsOpen={setIsOpen}
        />

        {error && (
          <div className="fixed bottom-8 left-1/2 -translate-x-1/2 bg-red-100 text-black px-6 py-3 rounded-full border border-red-300 shadow-lg font-serif italic text-sm z-50">
            {error}
          </div>
        )}
      </main>

      <style>{`
        body { overflow: hidden; }
      `}</style>
    </div>
  );
}
