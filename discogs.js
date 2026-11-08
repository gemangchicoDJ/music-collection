export async function onRequestGet({ request, env }) {
  const url = new URL(request.url);
  const artist = (url.searchParams.get("artist") || "").trim();
  const title = (url.searchParams.get("title") || "").trim();
  const year = (url.searchParams.get("year") || "").trim();
  if (!artist || !title) return Response.json({ error: "Indica artista y título." }, { status: 400 });
  if (!env.DISCOGS_TOKEN) return Response.json({ error: "Falta configurar DISCOGS_TOKEN en Cloudflare Pages > Settings > Variables and Secrets." }, { status: 503 });
  const q = new URLSearchParams({ type: "release", artist, track: title, per_page: "10" });
  if (year) q.set("year", year);
  const response = await fetch("https://api.discogs.com/database/search?" + q.toString(), {
    headers: { "Authorization": `Discogs token=${env.DISCOGS_TOKEN}`, "User-Agent": "MusicCollectionApp/1.0" }
  });
  if (!response.ok) return Response.json({ error: `Discogs respondió con estado ${response.status}.` }, { status: 502 });
  const data = await response.json();
  return Response.json({ results: data.results || [] }, { headers: { "Cache-Control": "private, max-age=60" } });
}