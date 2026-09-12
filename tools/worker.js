/**
 * 걷기명상 사전접수 — 신청 받는 Worker
 *
 * 두 가지 일을 합니다.
 *   1) 신청 페이지가 보낸 내용을 받아, 비공개 저장소의 CSV 에 한 줄씩 붙입니다. (POST)
 *   2) 구글시트가 명단을 읽어갈 수 있게 CSV 를 내어 줍니다. (GET, 열쇠 필요)
 *
 * Cloudflare Workers 에 그대로 붙여 넣으면 됩니다. 설치 방법은 SETUP-신청받기.md 참고.
 *
 * 필요한 설정 (Cloudflare 대시보드에서 넣습니다)
 *   GITHUB_TOKEN  비밀 — 비공개 저장소에 쓸 수 있는 GitHub 토큰
 *   LIST_KEY      비밀 — 명단을 읽어갈 때 쓰는 열쇠. 직접 정하시면 됩니다
 *   GITHUB_REPO   일반 — aassan9979-art/walking-meditation-applications
 *   FILE_PATH     일반 — data/applications.csv
 *   ALLOW_ORIGIN  일반 — https://aassan9979-art.github.io
 */

export default {
  async fetch(request, env) {
    const origin = env.ALLOW_ORIGIN || "https://aassan9979-art.github.io";
    const cors = {
      "Access-Control-Allow-Origin": origin,
      "Access-Control-Allow-Methods": "POST, OPTIONS",
      "Access-Control-Allow-Headers": "Content-Type",
      "Access-Control-Max-Age": "86400",
      Vary: "Origin",
    };

    const api =
      "https://api.github.com/repos/" + env.GITHUB_REPO + "/contents/" + env.FILE_PATH;
    const headers = {
      Authorization: "Bearer " + env.GITHUB_TOKEN,
      Accept: "application/vnd.github+json",
      "X-GitHub-Api-Version": "2022-11-28",
      "User-Agent": "walking-meditation-form",
    };

    if (request.method === "OPTIONS") {
      return new Response(null, { status: 204, headers: cors });
    }

    // ---- 구글시트가 명단을 읽어가는 곳 ----
    if (request.method === "GET") {
      const key = new URL(request.url).searchParams.get("key");
      // 열쇠가 없거나 틀리면, 이런 주소가 있다는 것조차 알리지 않습니다
      if (!env.LIST_KEY || key !== env.LIST_KEY) {
        return new Response("Not found", { status: 404 });
      }
      const res = await fetch(api, { headers });
      if (!res.ok) {
        return new Response("명단을 읽지 못했습니다", { status: 502 });
      }
      const meta = await res.json();
      const text = fromBase64(String(meta.content).replace(/\s/g, ""));
      // 맨 앞 BOM 은 떼고 보냅니다. 그대로 두면 첫 칸 글자가 깨져 보입니다.
      return new Response(text.replace(/^﻿/, ""), {
        status: 200,
        headers: {
          "Content-Type": "text/csv; charset=utf-8",
          "Cache-Control": "no-store",
        },
      });
    }

    if (request.method !== "POST") {
      return reply({ ok: false, error: "method" }, 405, cors);
    }

    // ---- 신청 받기 ----
    let body;
    try {
      body = await request.json();
    } catch {
      return reply({ ok: false, error: "bad_json" }, 400, cors);
    }

    // 자동 등록 로봇 거르기: 사람에게는 보이지 않는 칸이 채워져 있으면 조용히 무시
    if (body.website) {
      return reply({ ok: true }, 200, cors);
    }

    const attend = trim(body.attend, 40);
    const count = trim(body.count, 40);
    const people = trim(body.people, 2000);
    const phone = trim(body.phone, 40);

    if (!attend) {
      return reply({ ok: false, error: "missing_attend" }, 400, cors);
    }
    if (attend.startsWith("참석합니다") && !phone) {
      return reply({ ok: false, error: "missing_phone" }, 400, cors);
    }

    const now = kstNow();
    const row = [now, attend, count, people, dashPhone(phone)].map(csvCell).join(",") + "\r\n";

    // 같은 순간에 두 사람이 신청하면 충돌이 납니다. 다시 읽어서 몇 번 재시도합니다.
    for (let attempt = 0; attempt < 5; attempt++) {
      const current = await fetch(api, { headers });
      if (!current.ok) {
        return reply({ ok: false, error: "read_failed" }, 502, cors);
      }
      const meta = await current.json();
      const text = fromBase64(String(meta.content).replace(/\s/g, ""));

      const saved = await fetch(api, {
        method: "PUT",
        headers: { ...headers, "Content-Type": "application/json" },
        body: JSON.stringify({
          message: "신청 " + now,
          content: toBase64(text + row),
          sha: meta.sha,
        }),
      });

      if (saved.ok) {
        return reply({ ok: true }, 200, cors);
      }
      if (saved.status !== 409) {
        return reply({ ok: false, error: "write_failed" }, 502, cors);
      }
      await sleep(200 + Math.floor(Math.random() * 500));
    }

    return reply({ ok: false, error: "busy" }, 503, cors);
  },
};

function reply(obj, status, cors) {
  return new Response(JSON.stringify(obj), {
    status,
    headers: { ...cors, "Content-Type": "application/json; charset=utf-8" },
  });
}

function trim(value, max) {
  return String(value == null ? "" : value).trim().slice(0, max);
}

function csvCell(value) {
  return '"' + String(value).replace(/"/g, '""') + '"';
}

/**
 * 연락처에 하이픈을 넣습니다.
 * 숫자만 있으면 구글시트가 숫자로 바꿔 버려서 010 의 맨 앞 0 이 사라집니다.
 * 하이픈이 하나라도 있으면 글자로 남습니다.
 */
function dashPhone(value) {
  const raw = String(value).trim();
  if (raw.indexOf("-") !== -1) return raw;

  const d = raw.replace(/[^0-9]/g, "");
  if (d !== raw.replace(/\s/g, "") || d.charAt(0) !== "0") return raw;

  if (d.length === 11) return d.slice(0, 3) + "-" + d.slice(3, 7) + "-" + d.slice(7);
  if (d.length === 10) {
    return d.slice(0, 2) === "02"
      ? d.slice(0, 2) + "-" + d.slice(2, 6) + "-" + d.slice(6)
      : d.slice(0, 3) + "-" + d.slice(3, 6) + "-" + d.slice(6);
  }
  if (d.length === 9 && d.slice(0, 2) === "02") {
    return d.slice(0, 2) + "-" + d.slice(2, 5) + "-" + d.slice(5);
  }
  return raw;
}

function kstNow() {
  const t = new Date(Date.now() + 9 * 60 * 60 * 1000);
  return t.toISOString().replace("T", " ").slice(0, 19);
}

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

// 파일 맨 앞의 BOM 을 그대로 지켜야 Excel 에서 한글이 깨지지 않습니다.
function fromBase64(b64) {
  const bin = atob(b64);
  const bytes = new Uint8Array(bin.length);
  for (let i = 0; i < bin.length; i++) bytes[i] = bin.charCodeAt(i);
  return new TextDecoder("utf-8", { ignoreBOM: true }).decode(bytes);
}

function toBase64(text) {
  const bytes = new TextEncoder().encode(text);
  let bin = "";
  for (let i = 0; i < bytes.length; i++) bin += String.fromCharCode(bytes[i]);
  return btoa(bin);
}
