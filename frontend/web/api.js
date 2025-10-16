function getQueryParam(name){
  const params = new URLSearchParams(window.location.search);
  return params.get(name);
}

function resolveBaseUrl(){
  const fromParam = getQueryParam('api');
  if (fromParam) {
    try { localStorage.setItem('dons_api_base_url', fromParam); } catch(_) {}
    return fromParam.replace(/\/$/, '');
  }
  try {
    const saved = localStorage.getItem('dons_api_base_url');
    if (saved) return saved.replace(/\/$/, '');
  } catch(_) {}
  return 'http://localhost:8000/api';
}

const ApiConfig = {
  baseUrl: resolveBaseUrl(),
  storageTokenKey: 'dons_admin_token'
};

function getAuthToken() {
  return localStorage.getItem(ApiConfig.storageTokenKey);
}

function setAuthToken(token) {
  if (token) {
    localStorage.setItem(ApiConfig.storageTokenKey, token);
  } else {
    localStorage.removeItem(ApiConfig.storageTokenKey);
  }
}

function encodeBody(body, contentType){
  if (!body) return undefined;
  if (contentType === 'application/json') return JSON.stringify(body);
  const params = new URLSearchParams();
  Object.keys(body).forEach(k => {
    const v = body[k];
    if (v === undefined || v === null) return;
    params.set(k, typeof v === 'object' ? JSON.stringify(v) : String(v));
  });
  return params;
}

async function apiRequest(path, { method = 'GET', body, auth = false, headers = {}, json = false } = {}) {
  const defaultContentType = json ? 'application/json' : 'application/x-www-form-urlencoded;charset=UTF-8';
  const fetchHeaders = { 'Accept': 'application/json', 'Content-Type': defaultContentType, ...headers };
  if (auth) {
    const token = getAuthToken();
    if (!token) throw new Error('NOT_AUTHENTICATED');
    fetchHeaders['Authorization'] = `Bearer ${token}`;
  }

  const res = await fetch(`${ApiConfig.baseUrl}${path}`, {
    method,
    headers: fetchHeaders,
    body: encodeBody(body, fetchHeaders['Content-Type'])
  });

  const text = await res.text();
  let data;
  try { data = text ? JSON.parse(text) : {}; } catch (_) { data = { raw: text }; }

  if (!res.ok) {
    const message = (data && (data.message || data.error)) || `HTTP ${res.status}`;
    const error = new Error(message);
    error.status = res.status;
    error.data = data;
    throw error;
  }
  return data;
}

const AuthApi = {
  async login({ phone_number, password }) {
    const result = await apiRequest('/login', { method: 'POST', body: { phone_number, password }, json: true });
    if (result && result.token) setAuthToken(result.token);
    return result;
  },
  async register(payload) {
    return apiRequest('/register', { method: 'POST', body: payload, json: true });
  },
  async me() {
    return apiRequest('/user', { auth: true });
  },
  async logout() {
    try { await apiRequest('/logout', { method: 'POST', auth: true }); } catch (_) {}
    setAuthToken(null);
  }
};

const PaymentsApi = {
  async list({ status, payment_method, page } = {}) {
    const params = new URLSearchParams();
    if (status) params.set('status', status);
    if (payment_method) params.set('payment_method', payment_method);
    if (page) params.set('page', page);
    const query = params.toString() ? `?${params}` : '';
    return apiRequest(`/payments${query}`, { auth: true });
  }
};

const AdminApi = {
  async dashboard() { return apiRequest('/admin/dashboard'); },
  // Groups
  async getGroups() { return apiRequest('/admin/groups'); },
  async createGroup(payload) { return apiRequest('/admin/groups', { method: 'POST', body: payload }); },
  async deleteGroup(id) { return apiRequest(`/admin/groups/${id}`, { method: 'DELETE' }); },

  // Members
  async listMembers() { return apiRequest('/admin/members'); },
  async createMember(payload) { return apiRequest('/admin/members', { method: 'POST', body: payload }); },
  async availableGroups() { return apiRequest('/admin/members/available-groups'); },
  async addToGroup(payload) { return apiRequest('/admin/members/add-to-group', { method: 'POST', body: payload }); },
  async removeFromGroup(payload) { return apiRequest('/admin/members/remove-from-group', { method: 'POST', body: payload }); },

  // Reports
  async reportMembers(payload={}) { return apiRequest('/admin/reports/members', { method: 'POST', body: payload }); },
  async reportContributions(payload={}) { return apiRequest('/admin/reports/contributions', { method: 'POST', body: payload }); },
  async reportGroups(payload={}) { return apiRequest('/admin/reports/groups', { method: 'POST', body: payload }); },

  // Export
  async exportExcel(payload={}) { return apiRequest('/admin/export/excel', { method: 'POST', body: payload }); },
  async exportPDF(payload={}) { return apiRequest('/admin/export/pdf', { method: 'POST', body: payload }); },
  async exportCSV(payload={}) { return apiRequest('/admin/export/csv', { method: 'POST', body: payload }); },
};

window.DonsApi = { AuthApi, PaymentsApi, AdminApi, setAuthToken, getAuthToken };

