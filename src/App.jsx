import { useEffect, useState } from 'react'
import { supabase } from './lib/supabaseClient'
import './App.css'

const STATUS_LABELS = {
  available: 'Available',
  loading: 'Loading',
  delivering: 'Delivering',
  returning: 'Returning',
  maintenance: 'Maintenance',
}

function App() {
  const [trucks, setTrucks] = useState([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(null)

  useEffect(() => {
    fetchTrucks()

    const channel = supabase
      .channel('trucks-live')
      .on(
        'postgres_changes',
        { event: '*', schema: 'public', table: 'trucks' },
        () => fetchTrucks()
      )
      .subscribe()

    return () => {
      supabase.removeChannel(channel)
    }
  }, [])

  async function fetchTrucks() {
    setLoading(true)
    const { data, error } = await supabase
      .from('trucks')
      .select('id, truck_number, driver_name, status, current_job, loads_today')
      .order('truck_number', { ascending: true })

    if (error) {
      setError(error.message)
    } else {
      setError(null)
      setTrucks(data ?? [])
    }
    setLoading(false)
  }

  return (
    <div className="board">
      <header className="board-header">
        <div>
          <p className="board-eyebrow">Dispatch board</p>
          <h1>Fleet status</h1>
        </div>
        <div className="board-clock">{new Date().toLocaleDateString()}</div>
      </header>

      {error && (
        <div className="board-notice">
          Couldn't reach the <code>trucks</code> table yet — {error}. This is
          expected until the Supabase schema is created; see README.
        </div>
      )}

      {!error && !loading && trucks.length === 0 && (
        <div className="board-notice">
          Connected to Supabase, but no trucks are set up yet. Add rows to
          the <code>trucks</code> table to see them here.
        </div>
      )}

      <div className="truck-grid">
        {trucks.map((truck) => (
          <div key={truck.id} className={`truck-card status-${truck.status}`}>
            <div className="truck-card-top">
              <span className="truck-number">Truck {truck.truck_number}</span>
              <span className="truck-status">{STATUS_LABELS[truck.status] ?? truck.status}</span>
            </div>
            <p className="truck-driver">{truck.driver_name ?? 'Unassigned'}</p>
            <p className="truck-job">{truck.current_job ?? '—'}</p>
            <p className="truck-loads">{truck.loads_today ?? 0} loads today</p>
          </div>
        ))}
      </div>
    </div>
  )
}

export default App
