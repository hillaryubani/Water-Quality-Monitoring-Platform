;; Sensor Data Management Contract

(define-data-var next-sensor-id uint u0)

(define-map sensors
  { sensor-id: uint }
  {
    owner: principal,
    location: (string-utf8 100),
    sensor-type: (string-ascii 20),
    last-reading: uint,
    last-update: uint
  }
)

(define-map sensor-readings
  { sensor-id: uint, timestamp: uint }
  {
    ph: uint,
    temperature: uint,
    turbidity: uint,
    dissolved-oxygen: uint
  }
)

(define-public (register-sensor (location (string-utf8 100)) (sensor-type (string-ascii 20)))
  (let
    ((new-id (var-get next-sensor-id))
     (owner tx-sender))
    (map-set sensors
      { sensor-id: new-id }
      {
        owner: owner,
        location: location,
        sensor-type: sensor-type,
        last-reading: u0,
        last-update: u0
      }
    )
    (var-set next-sensor-id (+ new-id u1))
    (ok new-id)
  )
)

(define-public (record-reading (sensor-id uint) (ph uint) (temperature uint) (turbidity uint) (dissolved-oxygen uint))
  (let
    ((owner tx-sender)
     (timestamp block-height))
    (match (map-get? sensors { sensor-id: sensor-id })
      sensor (begin
        (asserts! (is-eq owner (get owner sensor)) (err u403))
        (map-set sensor-readings
          { sensor-id: sensor-id, timestamp: timestamp }
          {
            ph: ph,
            temperature: temperature,
            turbidity: turbidity,
            dissolved-oxygen: dissolved-oxygen
          }
        )
        (map-set sensors
          { sensor-id: sensor-id }
          (merge sensor {
            last-reading: timestamp,
            last-update: timestamp
          })
        )
        (ok true)
      )
      (err u404)
    )
  )
)

(define-read-only (get-sensor (sensor-id uint))
  (map-get? sensors { sensor-id: sensor-id })
)

(define-read-only (get-reading (sensor-id uint) (timestamp uint))
  (map-get? sensor-readings { sensor-id: sensor-id, timestamp: timestamp })
)

(define-read-only (get-latest-reading (sensor-id uint))
  (match (map-get? sensors { sensor-id: sensor-id })
    sensor (map-get? sensor-readings { sensor-id: sensor-id, timestamp: (get last-reading sensor) })
    none
  )
)

