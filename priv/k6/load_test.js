import http from "k6/http";
import { check, sleep } from "k6";
import { Rate, Trend } from "k6/metrics";

const errorRate = new Rate("errors");
const listTrend = new Trend("list_users_duration");
const showTrend = new Trend("show_user_duration");

export const options = {
  stages: [
    { duration: "10s", target: 10 },  // ramp up
    { duration: "30s", target: 50 },  // sustained load
    { duration: "10s", target: 0 },   // ramp down
  ],
  thresholds: {
    http_req_failed: ["rate<0.01"],   // <1% errors
    http_req_duration: ["p(95)<500"], // 95% of requests under 500ms
  },
};

const BASE_URL = __ENV.BASE_URL || "http://localhost:4000";

export default function () {
  // GET /api/users (paginated list)
  const page = Math.floor(Math.random() * 10) + 1;
  const listRes = http.get(`${BASE_URL}/api/users?page=${page}&per_page=20`);

  check(listRes, {
    "list: status 200": (r) => r.status === 200,
    "list: has data": (r) => JSON.parse(r.body).data.length > 0,
  });

  errorRate.add(listRes.status !== 200);
  listTrend.add(listRes.timings.duration);

  // GET /api/users/:id (random user from the list)
  const body = JSON.parse(listRes.body);
  if (body.data && body.data.length > 0) {
    const user = body.data[Math.floor(Math.random() * body.data.length)];
    const showRes = http.get(`${BASE_URL}/api/users/${user.id}`);

    check(showRes, {
      "show: status 200": (r) => r.status === 200,
      "show: correct id": (r) => JSON.parse(r.body).id === user.id,
    });

    errorRate.add(showRes.status !== 200);
    showTrend.add(showRes.timings.duration);
  }

  sleep(0.5);
}
