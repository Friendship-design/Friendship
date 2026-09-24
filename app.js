const { data: { user } = {} } = await supabaseClient.auth.getUser();

async function loadHome(){
  const session = (await supabaseClient.auth.getSession()).data.session;
  if(!session){ location.href='pages/login.html'; return; }
  const {data: profile}=await supabaseClient.from('profiles').select('*').eq('id',session.user.id).single();
  document.querySelectorAll('[data-user-name]').forEach(e=>e.textContent=profile?.full_name || profile?.username || session.user.email.split('@')[0]);
  document.querySelectorAll('[data-user-email]').forEach(e=>e.textContent=session.user.email);
  const {data: posts,error}=await supabaseClient.from('posts').select('id,content,created_at,user_id,profiles(full_name,username,avatar_url)').order('created_at',{ascending:false}).limit(30);
  const feed=document.getElementById('feed'); if(!feed)return;
  if(error){feed.innerHTML='<div class="error">Gagal memuat feed.</div>';return;}
  feed.innerHTML=posts?.length?posts.map(p=>`<article class="post"><img src="${p.profiles?.avatar_url||'https://i.pravatar.cc/80'}"><div><b>${esc(p.profiles?.full_name||p.profiles?.username||'Pengguna')}</b><small>${new Date(p.created_at).toLocaleString('id-ID')}</small><p>${esc(p.content)}</p><div class="post-actions"><button onclick="toggleLike('${p.id}')">♡ Like</button><button>💬 Comment</button></div></div></article>`).join(''):'<p class="muted">Belum ada postingan. Jadilah yang pertama!</p>';
}
async function postStatus(){
  const el=document.getElementById('status'); const content=el.value.trim(); if(!content)return;
  const session=(await supabaseClient.auth.getSession()).data.session; if(!session)return;
  const {error}=await supabaseClient.from('posts').insert({user_id:session.user.id,content});
  if(error){alert(error.message);return} el.value=''; await loadHome();
}
async function toggleLike(postId){
  const session=(await supabaseClient.auth.getSession()).data.session;if(!session)return;
  const {data: existing}=await supabaseClient.from('likes').select('post_id').eq('post_id',postId).eq('user_id',session.user.id).maybeSingle();
  if(existing) await supabaseClient.from('likes').delete().eq('post_id',postId).eq('user_id',session.user.id); else await supabaseClient.from('likes').insert({post_id:postId,user_id:session.user.id});
}
async function logout(){await supabaseClient.auth.signOut();location.href='pages/login.html'}
function esc(s){return String(s??'').replace(/[&<>'"]/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;',"'":'&#39;','"':'&quot;'}[c]))}
window.postStatus=postStatus;window.toggleLike=toggleLike;window.logout=logout;window.loadHome=loadHome;
