from app import app


def client():
    app.config["TESTING"] = True
    return app.test_client()


def test_health_endpoint():
    resp = client().get("/health")
    assert resp.status_code == 200
    assert resp.get_json() == {"status": "ok"}


def test_home_page_renders():
    resp = client().get("/")
    assert resp.status_code == 200
    assert b"Jenkins" in resp.data


def test_api_info_has_expected_keys():
    data = client().get("/api/info").get_json()
    for key in ("version", "hostname", "python", "started_at"):
        assert key in data
