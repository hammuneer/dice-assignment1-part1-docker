import { useEffect, useState } from "react";

export default function App() {
  const [name, setName] = useState("World");
  const [message, setMessage] = useState("");
  const [info, setInfo] = useState(null);
  const [error, setError] = useState("");

  async function sayHello() {
    try {
      const res = await fetch(`/api/hello?name=${encodeURIComponent(name)}`);
      const data = await res.json();
      setMessage(data.message);
      setError("");
    } catch {
      setError("Could not reach the API.");
    }
  }

  useEffect(() => {
    fetch("/api/info")
      .then((res) => res.json())
      .then(setInfo)
      .catch(() => setError("Could not reach the API."));
    sayHello();
  }, []);

  return (
    <main className="card">
      <h1>🐳 Dice Docker Demo</h1>
      <p className="subtitle">React frontend + FastAPI backend in a single Docker image</p>

      <div className="row">
        <input value={name} onChange={(e) => setName(e.target.value)} placeholder="Your name" />
        <button onClick={sayHello}>Say hello</button>
      </div>

      {message && <p className="message">{message}</p>}
      {error && <p className="error">{error}</p>}

      {info && (
        <table>
          <tbody>
            {Object.entries(info).map(([key, value]) => (
              <tr key={key}>
                <th>{key}</th>
                <td>{value}</td>
              </tr>
            ))}
          </tbody>
        </table>
      )}
    </main>
  );
}
