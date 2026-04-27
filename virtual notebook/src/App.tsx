import { useState, useEffect, useMemo } from 'react';
import Notebook from './components/Notebook';
import { Story } from './types';
import { db } from './firebase';
import { collection, onSnapshot, query } from 'firebase/firestore';

export default function App() {
  const [stories, setStories] = useState<Story[]>([]);
  const [currentPage, setCurrentPage] = useState(0);
  const [isOpen, setIsOpen] = useState(false);
  const [theme, setTheme] = useState<'light' | 'dark'>('light');
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  // Calculate global page structure: [ToC, Story1, Story2, ...]
  const globalPages = useMemo(() => {
    const pages: any[] = [{ type: 'toc' }];
    stories.forEach((story, sIdx) => {
      pages.push({ 
        type: 'story', 
        storyIndex: sIdx, 
        isCover: true // Every story page in the notebook is a cover/preview
      });
    });
    return pages;
  }, [stories]);

  useEffect(() => {
    const q = query(collection(db, 'stories'));
    const unsubscribe = onSnapshot(q, (snapshot) => {
      const fetchedStories = snapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data()
      })) as Story[];
      setStories(fetchedStories);
      setLoading(false);
    }, (err) => {
      console.error('Firestore Error:', err);
      setError('Failed to fetch the vessel\'s records.');
      setLoading(false);
    });

    return () => unsubscribe();
  }, []);

  const toggleTheme = () => {
    setTheme(prev => {
      const next = prev === 'light' ? 'dark' : 'light';
      if (next === 'dark') document.documentElement.classList.add('dark');
      else document.documentElement.classList.remove('dark');
      return next;
    });
  };

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-parchment dark:bg-parchment-dark">
        <div className="animate-pulse text-black dark:text-stone-50 font-serif text-2xl italic">Consulting the Scribe's Archive...</div>
      </div>
    );
  }

  return (
    <div className={`min-h-screen transition-colors duration-1000 ${
      theme === 'dark' ? 'bg-stone-900' : 'bg-stone-200'
    }`}>
      <main className="relative flex items-center justify-center min-h-screen p-4 md:p-8">
        <Notebook 
          stories={stories} 
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
