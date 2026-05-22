import React, { useState, useEffect, useRef } from 'react';
import { collection, getDocs, addDoc, updateDoc, deleteDoc, doc, Timestamp, query } from 'firebase/firestore';
import { ref, uploadBytes, getDownloadURL } from 'firebase/storage';
import { signInWithPopup, GoogleAuthProvider, signOut, onAuthStateChanged, User } from 'firebase/auth';
import { db, auth, storage, handleFirestoreError, OperationType } from '../lib/firebase';
import { LogOut, Plus, Edit2, Trash2, Archive, CheckCircle, Database, X, UploadCloud } from 'lucide-react';
import MDEditor from '@uiw/react-md-editor';

const SAMPLE_ARTICLES = [
  {
    title: "Global Markets Rally as Tech Sector Shows Unexpected Resilience",
    subtitle: "Despite early quarter concerns, major technology firms report record-breaking earnings, driving indices to all-time highs and easing recession fears.",
    excerpt: "Despite early quarter concerns, major technology firms report record-breaking earnings.",
    author: "Sarah Jenkins",
    role: "Senior Financial Correspondent",
    date: "April 14, 2026",
    time: "2 hours ago",
    category: "Business",
    imageUrl: "https://picsum.photos/seed/markets/1200/800",
    contentArr: [
      "The global financial markets experienced an unprecedented surge today.",
      "At the heart of this rally are the quarterly earnings reports from the 'Big Tech' conglomerates."
    ],
    status: "published"
  },
  {
    title: "New Climate Accord Reached in Geneva Summit",
    subtitle: "World leaders agree on aggressive new carbon reduction targets for 2035.",
    excerpt: "World leaders agree on aggressive new carbon reduction targets for 2035.",
    author: "David Chen",
    role: "Environmental Editor",
    date: "April 14, 2026",
    time: "4 hours ago",
    category: "World",
    imageUrl: "https://picsum.photos/seed/climate/600/400",
    contentArr: [
      "World leaders gathered today to announce a bold new plan."
    ],
    status: "published"
  }
];

export default function AdminDashboard() {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);
  const [articles, setArticles] = useState<any[]>([]);

  const [authError, setAuthError] = useState<string | null>(null);
  const [isLoggingIn, setIsLoggingIn] = useState(false);
  const [editingArticle, setEditingArticle] = useState<any | null>(null);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [isUploadingImage, setIsUploadingImage] = useState(false);
  const [isDraggingImage, setIsDraggingImage] = useState(false);
  
  const [galleryImages, setGalleryImages] = useState<{url: string, name: string}[]>([]);
  const [isDraggingGallery, setIsDraggingGallery] = useState(false);
  const [isUploadingGallery, setIsUploadingGallery] = useState(false);
  const galleryInputRef = useRef<HTMLInputElement>(null);

  const fileInputRef = useRef<HTMLInputElement>(null);

  const handleGalleryUpload = async (file: File) => {
    if (!file) return;
    try {
      setIsUploadingGallery(true);
      const fileRef = ref(storage, `article_gallery/${Date.now()}_${file.name}`);
      await uploadBytes(fileRef, file);
      const url = await getDownloadURL(fileRef);
      setGalleryImages(prev => [...prev, { url, name: file.name }]);
    } catch (e: any) {
      console.error('Error uploading to gallery', e);
      alert(`Failed to upload image: ${e.message}. If this is a permission error, please ensure Firebase Storage is enabled in your Firebase Console and rules allow write access.`);
    } finally {
      setIsUploadingGallery(false);
      setIsDraggingGallery(false);
    }
  };

  const handleImageUpload = async (file: File) => {
    if (!file) return;
    try {
      setIsUploadingImage(true);
      const fileRef = ref(storage, `article_images/${Date.now()}_${file.name}`);
      await uploadBytes(fileRef, file);
      const url = await getDownloadURL(fileRef);
      setEditingArticle({ ...editingArticle, imageUrl: url });
    } catch (e: any) {
      console.error('Error uploading image', e);
      alert(`Failed to upload image: ${e.message}. If this is a permission error, please ensure Firebase Storage is enabled in your Firebase Console and rules allow write access.`);
    } finally {
      setIsUploadingImage(false);
      setIsDraggingImage(false);
    }
  };

  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, (currentUser) => {
      setUser(currentUser);
      setLoading(false);
      if (currentUser) {
        fetchArticles();
      }
    });
    return () => unsubscribe();
  }, []);

  const fetchArticles = async () => {
    try {
      setAuthError(null);
      const q = query(collection(db, 'articles'));
      const querySnapshot = await getDocs(q);
      const fetched = querySnapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));

      fetched.sort((a: any, b: any) => {
        const timeA = a.createdAt ? a.createdAt.toMillis() : 0;
        const timeB = b.createdAt ? b.createdAt.toMillis() : 0;
        return timeB - timeA;
      });

      setArticles(fetched);
    } catch (e) {
      handleFirestoreError(e, OperationType.LIST, 'articles');
    }
  };

  const handleLogin = async () => {
    if (isLoggingIn) return;
    setAuthError(null);
    setIsLoggingIn(true);
    const provider = new GoogleAuthProvider();
    provider.setCustomParameters({ prompt: 'select_account' });
    try {
      await signInWithPopup(auth, provider);
    } catch (error: any) {
      console.error("Auth popup error:", error);
      if (error.code === 'auth/popup-blocked') {
        setAuthError("Popup blocked by browser. Please allow popups, or open this app in a new tab (click the 'Open in new tab' button in the AI Studio toolbar) to login.");
      } else if (error.code === 'auth/cancelled-popup-request' || error?.message?.includes('Pending promise was never set')) {
        setAuthError("Popup was closed or blocked by iframe restrictions. Please open this app in a new tab to login.");
      } else {
        setAuthError(error.message || "Failed to authenticate. Try opening in a new tab.");
      }
    } finally {
      setIsLoggingIn(false);
    }
  };

  const handleLogout = () => signOut(auth);

  const seedDatabase = async () => {
    try {
      setLoading(true);
      for (const article of SAMPLE_ARTICLES) {
        const articleWithDate = {
          ...article,
          createdAt: Timestamp.now(),
        };
        await addDoc(collection(db, 'articles'), articleWithDate);
      }
      await fetchArticles();
    } catch (error) {
      console.error("Error seeding database:", error);
      alert("Failed to seed database: " + (error as Error).message);
    } finally {
      setLoading(false);
    }
  };

  const handleDelete = async (id: string) => {
    if (confirm("Are you sure you want to delete this article?")) {
      try {
        await deleteDoc(doc(db, 'articles', id));
        fetchArticles();
      } catch (e) {
        handleFirestoreError(e, OperationType.DELETE, `articles/${id}`);
      }
    }
  };

  const handleArchiveState = async (id: string, currentStatus: string) => {
    const newStatus = currentStatus === 'published' ? 'archived' : 'published';
    try {
      await updateDoc(doc(db, 'articles', id), { status: newStatus });
      fetchArticles();
    } catch (e) {
      handleFirestoreError(e, OperationType.UPDATE, `articles/${id}`);
    }
  };

  const openModal = (article: any = null) => {
    if (article) {
      setEditingArticle({ ...article });
    } else {
      setEditingArticle({
        title: "",
        subtitle: "",
        excerpt: "",
        author: user?.displayName || user?.email?.split('@')[0] || "Admin",
        role: "Editor",
        date: new Date().toLocaleDateString('en-US', { month: 'long', day: 'numeric', year: 'numeric' }),
        time: "Just now",
        category: "World",
        imageUrl: "",
        contentStr: "", // Assuming single field for inputting text
        status: "published"
      });
    }
    setIsModalOpen(true);
  };

  const closeModal = () => {
    setIsModalOpen(false);
    setEditingArticle(null);
  };

  const handleSave = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      setLoading(true);
      const articleData = { ...editingArticle };
      
      // Parse content string into array for simplistic rendering
      if (articleData.contentStr) {
        articleData.contentArr = articleData.contentStr.split('\n').filter((p: string) => p.trim() !== "");
      }

      if (articleData.id) {
        const id = articleData.id;
        delete articleData.id; // Don't save id in document
        articleData.updatedAt = Timestamp.now();
        await updateDoc(doc(db, 'articles', id), articleData);
      } else {
        articleData.createdAt = Timestamp.now();
        articleData.date = new Date().toLocaleDateString('en-US', { month: 'long', day: 'numeric', year: 'numeric' });
        articleData.time = new Date().toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit' });
        await addDoc(collection(db, 'articles'), articleData);
      }
      closeModal();
      fetchArticles();
    } catch (e) {
      console.error(e);
      alert("Failed to save article");
    } finally {
      setLoading(false);
    }
  };

  if (loading) return <div className="p-8 text-center">Loading...</div>;

  if (!user) {
    return (
      <div className="min-h-screen bg-gray-100 flex items-center justify-center p-4">
        <div className="bg-white p-8 rounded shadow-lg max-w-sm w-full text-center">
          <h1 className="text-2xl font-bold mb-6">Admin Login</h1>
          {authError && (
             <div className="mb-4 p-3 bg-red-100 border border-red-400 text-red-700 text-sm rounded text-left">
               {authError}
             </div>
          )}
          <button 
            onClick={handleLogin}
            disabled={isLoggingIn}
            className={`w-full text-white font-bold py-3 rounded transition ${isLoggingIn ? 'bg-blue-400 cursor-not-allowed' : 'bg-blue-600 hover:bg-blue-700'}`}
          >
            {isLoggingIn ? 'Opening popup...' : 'Sign In with Google'}
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-100 p-8">
      <div className="max-w-7xl mx-auto bg-white p-8 rounded shadow">
        <div className="flex justify-between items-center mb-8 pb-4 border-b">
          <h1 className="text-3xl font-black">Lensa Insignia - Admin</h1>
          <div className="flex items-center space-x-4">
            <span className="text-sm font-semibold">{user.email}</span>
            <button onClick={handleLogout} className="flex items-center space-x-1 text-red-600 hover:text-red-800">
              <LogOut size={16} /> <span>Logout</span>
            </button>
          </div>
        </div>

        <div className="flex justify-between items-center mb-4">
          <h2 className="text-xl font-bold">Articles Management</h2>
          <div className="flex space-x-2">
            <button 
              onClick={seedDatabase}
              className="flex items-center space-x-2 bg-indigo-600 text-white px-4 py-2 rounded text-sm hover:bg-indigo-700">
              <Database size={16} />
              <span>Seed Mock Articles</span>
            </button>
            <button 
              onClick={() => openModal()}
              className="flex items-center space-x-2 bg-black text-white px-4 py-2 rounded text-sm hover:bg-gray-800">
              <Plus size={16} />
              <span>Add New Article</span>
            </button>
          </div>
        </div>

        <div className="overflow-x-auto">
          <table className="w-full text-left border-collapse">
            <thead>
              <tr className="bg-gray-50 border-b">
                <th className="p-3 text-sm font-semibold">Title</th>
                <th className="p-3 text-sm font-semibold">Category</th>
                <th className="p-3 text-sm font-semibold">Date</th>
                <th className="p-3 text-sm font-semibold">Status</th>
                <th className="p-3 text-sm font-semibold text-right">Actions</th>
              </tr>
            </thead>
            <tbody>
              {articles.length === 0 ? (
                <tr>
                  <td colSpan={5} className="p-8 text-center text-gray-500">
                    No articles found in Firestore. You can seed the database later.
                  </td>
                </tr>
              ) : (
                articles.map(article => (
                  <tr key={article.id} className="border-b hover:bg-gray-50">
                    <td className="p-3">
                      <div className="font-bold">{article.title}</div>
                      <div className="text-xs text-gray-500">{article.author}</div>
                    </td>
                    <td className="p-3 text-sm">{article.category}</td>
                    <td className="p-3 text-sm">{article.date}</td>
                    <td className="p-3 text-sm">
                      <span className={`px-2 py-1 rounded text-xs font-bold ${article.status === 'archived' ? 'bg-yellow-100 text-yellow-800' : 'bg-green-100 text-green-800'}`}>
                        {article.status ? article.status.toUpperCase() : 'PUBLISHED'}
                      </span>
                    </td>
                    <td className="p-3 flex justify-end space-x-2">
                       <button onClick={() => openModal(article)} className="p-1.5 bg-blue-100 text-blue-600 rounded hover:bg-blue-200" title="Edit"><Edit2 size={16} /></button>
                       <button onClick={() => handleArchiveState(article.id, article.status)} className={`p-1.5 rounded ${article.status === 'archived' ? 'bg-green-100 text-green-600 hover:bg-green-200' : 'bg-yellow-100 text-yellow-600 hover:bg-yellow-200'}`} title={article.status === 'archived' ? 'Publish' : 'Archive'}>
                         {article.status === 'archived' ? <CheckCircle size={16} /> : <Archive size={16} />}
                       </button>
                       <button onClick={() => handleDelete(article.id)} className="p-1.5 bg-red-100 text-red-600 rounded hover:bg-red-200" title="Delete"><Trash2 size={16} /></button>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>
      
      {isModalOpen && editingArticle && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4 z-50">
          <div className="bg-white rounded-lg shadow-xl w-full max-w-2xl max-h-[90vh] overflow-y-auto">
            <div className="flex justify-between items-center p-6 border-b sticky top-0 bg-white">
              <h2 className="text-2xl font-bold">{editingArticle.id ? 'Edit Article' : 'New Article'}</h2>
              <button onClick={closeModal} className="text-gray-500 hover:text-gray-800"><X size={24} /></button>
            </div>
            
            <form onSubmit={handleSave} className="p-6 space-y-4">
              <div>
                <label className="block text-sm font-semibold mb-1">Title</label>
                <input required type="text" className="w-full border p-2 rounded" value={editingArticle.title} onChange={e => setEditingArticle({...editingArticle, title: e.target.value})} />
              </div>
              
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-semibold mb-1">Author</label>
                  <input required type="text" className="w-full border p-2 rounded" value={editingArticle.author} onChange={e => setEditingArticle({...editingArticle, author: e.target.value})} />
                </div>
                <div>
                  <label className="block text-sm font-semibold mb-1">Category</label>
                  <select required className="w-full border p-2 rounded" value={editingArticle.category} onChange={e => setEditingArticle({...editingArticle, category: e.target.value})}>
                    <option value="World">World</option>
                    <option value="Politics">Politics</option>
                    <option value="Business">Business</option>
                    <option value="Tech">Tech</option>
                    <option value="Science">Science</option>
                    <option value="Health">Health</option>
                    <option value="Sports">Sports</option>
                    <option value="Arts">Arts</option>
                  </select>
                </div>
              </div>

              <div>
                <label className="block text-sm font-semibold mb-1">Image URL or Upload</label>
                <div 
                  className={`border-2 border-dashed rounded-lg p-6 text-center transition-colors ${isDraggingImage ? 'border-blue-500 bg-blue-50' : 'border-gray-300 hover:border-gray-400'}`}
                  onDragOver={(e) => { e.preventDefault(); setIsDraggingImage(true); }}
                  onDragLeave={(e) => { e.preventDefault(); setIsDraggingImage(false); }}
                  onDrop={(e) => {
                    e.preventDefault();
                    setIsDraggingImage(false);
                    const file = e.dataTransfer.files?.[0];
                    if (file && file.type.startsWith('image/')) {
                      handleImageUpload(file);
                    }
                  }}
                >
                  {isUploadingImage ? (
                    <div className="text-blue-500 font-semibold flex items-center justify-center space-x-2">
                       <UploadCloud className="animate-bounce" /> <span>Uploading...</span>
                    </div>
                  ) : (
                    <div className="flex flex-col items-center space-y-2">
                      <input 
                        type="file" 
                        ref={fileInputRef} 
                        className="hidden" 
                        accept="image/*" 
                        onChange={(e) => {
                          const file = e.target.files?.[0];
                          if (file) handleImageUpload(file);
                        }} 
                      />
                      <UploadCloud className="text-gray-400" size={32} />
                      <p className="text-sm text-gray-600">
                        Drag and drop an image here, or{' '}
                        <button type="button" onClick={() => fileInputRef.current?.click()} className="text-blue-600 hover:underline">browse</button>
                      </p>
                      <span className="text-xs text-gray-400">or paste a URL below</span>
                    </div>
                  )}
                </div>
                <input type="url" placeholder="https://..." className="w-full border p-2 rounded mt-2" value={editingArticle.imageUrl || ''} onChange={e => setEditingArticle({...editingArticle, imageUrl: e.target.value})} />
                {editingArticle.imageUrl && (
                  <div className="mt-2 text-sm text-green-600 flex items-center space-x-1">
                    <CheckCircle size={14} /> <span className="truncate max-w-sm" title={editingArticle.imageUrl}>Image Set</span>
                  </div>
                )}
              </div>

              <div>
                <label className="block text-sm font-semibold mb-1">Excerpt</label>
                <textarea className="w-full border p-2 rounded" rows={2} value={editingArticle.excerpt || ''} onChange={e => setEditingArticle({...editingArticle, excerpt: e.target.value})}></textarea>
              </div>

              <div className="mb-4">
                <label className="block text-sm font-semibold mb-2">Media Gallery (for use in content)</label>
                <div 
                  className={`border-2 border-dashed rounded-lg p-4 text-center transition-colors flex flex-col items-center ${isDraggingGallery ? 'border-blue-500 bg-blue-50' : 'border-gray-300 hover:border-gray-400'}`}
                  onDragOver={(e) => { e.preventDefault(); setIsDraggingGallery(true); }}
                  onDragLeave={(e) => { e.preventDefault(); setIsDraggingGallery(false); }}
                  onDrop={(e) => {
                    e.preventDefault();
                    setIsDraggingGallery(false);
                    Array.from(e.dataTransfer.files).forEach(file => {
                      if (file.type.startsWith('image/')) {
                        handleGalleryUpload(file);
                      }
                    });
                  }}
                >
                  <input 
                    type="file" 
                    ref={galleryInputRef} 
                    className="hidden" 
                    accept="image/*" 
                    multiple
                    onChange={(e) => {
                      if (e.target.files) {
                        Array.from(e.target.files).forEach(file => {
                          handleGalleryUpload(file);
                        });
                      }
                    }} 
                  />
                  
                  {galleryImages.length > 0 && (
                    <div className="flex flex-wrap gap-4 mb-4 justify-center w-full">
                      {galleryImages.map((img, i) => (
                        <div key={i} className="relative group border rounded p-1 w-24 h-24 flex items-center justify-center bg-gray-50 overflow-hidden">
                          <img src={img.url} alt={img.name} className="h-full w-full object-cover" />
                          <div className="absolute inset-0 bg-black bg-opacity-70 flex flex-col items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity">
                            <button 
                              type="button" 
                              className="text-white text-xs font-bold mb-1 hover:text-blue-300"
                              onClick={(e) => {
                                  e.preventDefault(); 
                                  const markdownImg = `\n![${img.name}](${img.url})\n`;
                                  const textarea = document.querySelector('textarea.w-md-editor-text-input') as HTMLTextAreaElement;
                                  
                                  setEditingArticle(prev => {
                                    const currentContent = prev.contentStr || '';
                                    if (textarea) {
                                      const start = textarea.selectionStart;
                                      const end = textarea.selectionEnd;
                                      const newContent = currentContent.substring(0, start) + markdownImg + currentContent.substring(end);
                                      
                                      setTimeout(() => {
                                        textarea.focus();
                                        textarea.setSelectionRange(start + markdownImg.length, start + markdownImg.length);
                                      }, 10);
                                      
                                      return { ...prev, contentStr: newContent };
                                    } else {
                                      return { ...prev, contentStr: currentContent + `\n\n${markdownImg}\n\n` };
                                    }
                                  });
                              }}
                            >
                              Insert
                            </button>
                            <button
                                type="button"
                                className="text-gray-300 text-xs hover:text-white"
                                onClick={(e) => {
                                    e.preventDefault();
                                    navigator.clipboard.writeText(`![${img.name}](${img.url})`);
                                    alert('Markdown copied to clipboard!');
                                }}
                            >
                                Copy
                            </button>
                          </div>
                        </div>
                      ))}
                    </div>
                  )}

                  <div className="flex flex-col items-center space-y-1">
                    {isUploadingGallery ? (
                      <div className="text-blue-500 font-semibold flex items-center space-x-2">
                        <UploadCloud className="animate-bounce" size={20} /> <span>Uploading...</span>
                      </div>
                    ) : (
                      <UploadCloud className="text-gray-400" size={28} />
                    )}
                    <p className="text-sm text-gray-600 mt-2">
                      Drag & drop images here, or <button type="button" onClick={() => galleryInputRef.current?.click()} className="text-blue-600 hover:underline">browse</button>.
                    </p>
                    <span className="text-xs text-gray-400">Place your cursor in the content editor below, then hover over an image and click <strong>Insert</strong> to add it exactly where you want.</span>
                  </div>
                </div>
              </div>

              <div data-color-mode="light">
                <div className="flex justify-between items-center mb-1">
                  <label className="block text-sm font-semibold">Content (Markdown format)</label>
                  <label className="cursor-pointer text-sm bg-gray-100 px-2 py-1 rounded border hover:bg-gray-200">
                    <input type="file" accept=".pdf,.docx,.txt,.md" className="hidden" onChange={async (e) => {
                      const file = e.target.files?.[0];
                      if (file) {
                        try {
                          const { parseDocument } = await import('../lib/fileParser');
                          const content = await parseDocument(file);
                          setEditingArticle(prev => ({...prev, contentStr: prev.contentStr ? prev.contentStr + '\n\n' + content : content}));
                        } catch (error) {
                          alert('Error parsing document: ' + (error as Error).message);
                        }
                      }
                      e.target.value = '';
                    }} />
                    <span>Upload Document (.pdf, .docx)</span>
                  </label>
                </div>
                <div className="border rounded overflow-hidden">
                  <MDEditor
                    value={editingArticle.contentStr || (editingArticle.contentArr ? editingArticle.contentArr.join('\n\n') : '')}
                    onChange={(val) => setEditingArticle({...editingArticle, contentStr: val || ''})}
                    height={400}
                  />
                </div>
              </div>
              
              <div className="pt-4 flex justify-end space-x-3">
                <button type="button" onClick={closeModal} className="px-4 py-2 border rounded hover:bg-gray-50">Cancel</button>
                <button type="submit" className="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700">Save Article</button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
