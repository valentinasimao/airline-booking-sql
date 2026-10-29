"""
Generates a realistic, reproducible sample dataset for the airline seat-management project.
Output: CSV files in ../data (one per table). Run:  python scripts/generate_data.py
"""
import csv, random, string
from datetime import datetime, timedelta, date
from pathlib import Path

random.seed(42)
OUT = Path(__file__).resolve().parent.parent / "data"
OUT.mkdir(exist_ok=True)
TODAY = datetime(2026, 10, 29, 6, 0)

def write(name, header, rows):
    with open(OUT / f"{name}.csv", "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f); w.writerow(header); w.writerows(rows)

# ---------------- airports ----------------
airports = [("BCN","Barcelona","Spain"),("MAD","Madrid","Spain"),("LIS","Lisbon","Portugal"),
            ("FCO","Rome","Italy"),("CDG","Paris","France"),("LHR","London","United Kingdom"),
            ("JFK","New York","United States"),("GRU","São Paulo","Brazil")]
write("airports", ["airport_code","city","country"], airports)

# ---------------- aircraft & seat maps ----------------
# layout: list of (cabin, first_row, last_row, letters, aisle_letters, exit_rows)
layouts = {
    1: ("Airbus A320neo", [("Business",1,4,"ACDF","CD",[]), ("Economy",5,31,"ABCDEF","CD",[12,13])]),
    2: ("Boeing 737-800", [("Business",1,3,"ACDF","CD",[]), ("Economy",4,32,"ABCDEF","CD",[15,16])]),
    3: ("Airbus A330-300",[("Business",1,6,"ADGK","DG",[]), ("Premium",10,14,"ACDEFGHK","CDGH",[]),
                           ("Economy",20,45,"ABCDEFGHK","CDFG",[20,33])]),
}
aircraft_rows, seat_rows, seats_by_type = [], [], {}
for at_id,(model,cabins) in layouts.items():
    seats=[]
    for cabin,r1,r2,letters,aisles,exits in cabins:
        for r in range(r1, r2+1):
            for i,l in enumerate(letters):
                if i==0 or i==len(letters)-1: st="Window"
                elif l in aisles: st="Aisle"
                else: st="Middle"
                seats.append((at_id,f"{r}{l}",r,l,i+1,cabin,st,r in exits))
    seats_by_type[at_id]=seats; seat_rows+=seats
    aircraft_rows.append((at_id,model,len(seats)))
write("aircraft_types", ["aircraft_type_id","model","total_seats"], aircraft_rows)
write("seat_map", ["aircraft_type_id","seat_no","row_no","seat_letter","letter_pos","cabin","seat_type","is_exit_row"], seat_rows)

# ---------------- flights ----------------
routes = [("MAD",1,"ZZ1001",[7,13,19]),("LIS",2,"ZZ1201",[9,17]),("FCO",1,"ZZ1301",[8,16]),
          ("CDG",2,"ZZ1401",[7,18]),("LHR",1,"ZZ1501",[10]),("JFK",3,"ZZ2001",[11]),("GRU",3,"ZZ2101",[23])]
flights=[]; fid=0
start = date(2026,10,15)
for d in range(21):
    day = start + timedelta(days=d)
    for dest,at,fno,hours in routes:
        if dest in ("JFK","GRU") and d % 2: continue          # long-haul every other day
        for k,h in enumerate(hours):
            fid+=1
            dep = datetime(day.year,day.month,day.day,h,random.choice([0,15,30,45]))
            flights.append([fid, fno[:-1]+str(int(fno[-1])+k*2), "BCN", dest, dep, at,
                            "Departed" if dep < TODAY else "Scheduled"])
write("flights", ["flight_id","flight_no","origin","destination","departure_ts","aircraft_type_id","status"], flights)

# ---------------- passengers ----------------
first = ["Laura","Marc","Júlia","Pau","Sofia","Jordi","Marta","David","Ana","Pedro","Lucía","Carlos","Emma","Luca",
         "Giulia","Matteo","Chloé","Hugo","Olivia","James","Mia","Noah","Beatriz","João","Mariana","Rafael","Elena","Àlex"]
last = ["García","Martínez","Puig","Ferrer","Rossi","Bianchi","Dubois","Martin","Smith","Johnson","Silva","Santos",
        "Oliveira","Costa","López","Sánchez","Vidal","Serra","Romano","Moreau","Brown","Wilson","Pereira","Ribeiro"]
tiers = (["None"]*60)+(["Silver"]*22)+(["Gold"]*13)+(["Platinum"]*5)
passengers=[]
for pid in range(1, 6501):
    tier=random.choice(tiers)
    pts={"None":random.randint(0,4000),"Silver":random.randint(5000,20000),
         "Gold":random.randint(20000,60000),"Platinum":random.randint(60000,150000)}[tier]
    passengers.append([pid, random.choice(first), random.choice(last),
                       date(1950,1,1)+timedelta(days=random.randint(0,365*55)), tier, pts])
pmap={p[0]:p for p in passengers}

def child_birth(dep):  # child aged 4-13 at departure
    return (dep - timedelta(days=random.randint(4*365, 13*365))).date()

# ---------------- bookings, tickets, seats ----------------
fare_base={"Business":(380,900),"Premium":(250,520),"Economy":(45,260)}
longhaul_mult={1:1.0,2:1.0,3:2.6}
bookings, tickets, seat_assign, upgrades = [], [], [], []
bid=tid=rid=0; used_refs=set(); next_pid=1
def new_ref():
    while True:
        r="".join(random.choices(string.ascii_uppercase+string.digits,k=6))
        if r not in used_refs: used_refs.add(r); return r

for f in flights:
    fid_, _, _, dest, dep, at, status = f
    seats = seats_by_type[at]
    by_cabin={}
    for s in seats: by_cabin.setdefault(s[5],[]).append(s)
    taken=set(); flight_pax=set()
    for cabin, cseats in by_cabin.items():
        cap=len(cseats)
        load = random.uniform(0.62, 1.12) if cabin=="Economy" else random.uniform(0.45, 0.95)
        if cabin=="Economy" and status=="Scheduled" and random.random()<0.1: load=random.uniform(1.14,1.22)  # peak demand
        n_tix = int(cap*load)
        sold=0
        while sold < n_tix:
            bid+=1; group=random.choices([1,2,3,4],[55,25,12,8])[0]
            booked_at = dep - timedelta(days=random.randint(1,90), hours=random.randint(0,23))
            if booked_at > TODAY:                    # nobody can book in the future
                booked_at = TODAY - timedelta(hours=1 + bid % 72)
            bookings.append([bid,new_ref(),booked_at,random.choice(["Web","Web","App","App","Agency"])])
            family_children = group>=3 and random.random()<0.6
            lead_last=None; group_tix=[]
            for g in range(group):
                if sold>=n_tix: break
                pid=random.randint(1,6500)
                while pid in flight_pax: pid=random.randint(1,6500)
                if g==0: lead_last=pmap[pid][2]
                is_child = family_children and g>=2
                if is_child:                            # child traveller: new passenger record
                    pid=len(passengers)+1
                    passengers.append([pid, random.choice(first), lead_last, child_birth(dep), "None", 0])
                flight_pax.add(pid); tid+=1; sold+=1
                lo,hi=fare_base[cabin]; fare=round(random.uniform(lo,hi)*longhaul_mult[at],2)
                pref=random.choices(["Window","Aisle",None],[38,30,32])[0]
                if status=="Departed":
                    st=random.choices(["Boarded","NoShow","Cancelled"],[90,6,4])[0]
                else:
                    st=random.choices(["Confirmed","Cancelled"],[95,5])[0]
                tickets.append([tid,bid,pid,fid_,cabin,fare,pref,st])
                group_tix.append((tid,pref,st,is_child))
                if status=="Scheduled" and st=="Confirmed" and cabin!="Business" and random.random()<0.05:
                    rid+=1
                    upgrades.append([rid,tid,"Business" if cabin=="Economy" or random.random()<.7 else "Premium",
                                     min(dep-timedelta(days=random.randint(0,10),hours=random.randint(0,23)),
                                         TODAY-timedelta(minutes=rid))])
            # ---- seat the group ----
            seatable=[x for x in group_tix if x[2]!="Cancelled" and (status=="Departed" or random.random()<0.72)]
            if not seatable: continue
            free=[s for s in cseats if s[1] not in taken]
            has_child=any(x[3] for x in seatable)
            chosen=[]
            if len(seatable)>1 and random.random()<0.88:          # most groups sit together
                rows={}
                for s_ in free:
                    if has_child and s_[7]: continue
                    rows.setdefault(s_[2],[]).append(s_)
                blocks=[]
                for r,ss in rows.items():
                    ss=sorted(ss,key=lambda z:z[4])
                    for i in range(len(ss)-len(seatable)+1):
                        blk=ss[i:i+len(seatable)]
                        if all(blk[k+1][4]-blk[k][4]==1 for k in range(len(blk)-1)): blocks.append(blk)
                if blocks: chosen=random.choice(blocks)
            atype=random.choices(["Selected","Auto"],[70,30])[0]
            for i,(tid_,pref,st,is_child) in enumerate(seatable):
                if chosen: seat=chosen[i]
                else:
                    free=[s_ for s_ in cseats if s_[1] not in taken and not (is_child and s_[7])]
                    if is_child and random.random()<0.015:        # rare data-quality issue to detect
                        ex=[s_ for s_ in cseats if s_[1] not in taken and s_[7]]
                        free=ex or free
                    if not free: break
                    hit = 0.9 if atype=="Selected" else 0.45
                    cand=[s_ for s_ in free if pref and s_[6]==pref] if random.random()<hit else []
                    seat=random.choice(cand or free)
                taken.add(seat[1])
                seat_assign.append([tid_,fid_,seat[1],min(booked_at+timedelta(hours=random.randint(1,48)),TODAY),atype])

write("passengers", ["passenger_id","first_name","last_name","birth_date","loyalty_tier","loyalty_points"], passengers)
write("bookings", ["booking_id","booking_ref","booked_at","channel"], bookings)
write("tickets", ["ticket_id","booking_id","passenger_id","flight_id","cabin_booked","fare_eur","seat_preference","status"], tickets)
write("seat_assignments", ["ticket_id","flight_id","seat_no","assigned_at","assignment_type"], seat_assign)
write("upgrade_requests", ["request_id","ticket_id","requested_cabin","requested_at"], upgrades)
print(f"flights={len(flights)} passengers={len(passengers)} bookings={len(bookings)} tickets={len(tickets)} "
      f"seats={len(seat_assign)} upgrades={len(upgrades)}")


# ======================================================================
# Booking website: checkout sessions, payment attempts and refunds
# (separate random stream so the seat data above stays identical)
# ======================================================================
rng = random.Random(2026)
SEAT_FEE = 12.00                     # fee for choosing your own seat (not charged in Business)
flight_by_id = {f[0]: f for f in flights}
tix_by_booking = {}
for t_ in tickets: tix_by_booking.setdefault(t_[1], []).append(t_)
selected = {s[0] for s in seat_assign if s[4] == "Selected"}

methods = {"Web": ["Card","Card","Card","PayPal","Bizum","Apple Pay"],
           "App": ["Card","Card","Apple Pay","Apple Pay","Google Pay","Bizum"],
           "Agency": ["Bank transfer"]}
fail_rate = {"Card":0.14,"PayPal":0.06,"Bizum":0.05,"Apple Pay":0.03,"Google Pay":0.04,"Bank transfer":0.01}
reasons = ["Card declined","3-D Secure failed","Insufficient funds","Timeout","Transfer not received"]
reason_w = {"Card":[40,35,20,5,0],"PayPal":[30,0,40,30,0],"Bizum":[20,0,50,30,0],
            "Apple Pay":[50,0,30,20,0],"Google Pay":[50,0,30,20,0],"Bank transfer":[0,0,0,0,100]}
STEPS = ["Search","Seats","Passenger details","Payment","Paid"]

# promo codes (fictional campaigns): code, campaign, type, value, min spend, valid from, valid to, max uses, channel, destination
promos = [
    ("WELCOME10", "New customer welcome",  "Percent", 10, None, datetime(2026,1,1),  datetime(2026,12,31,23,59), None, None,  None),
    ("SUMMER25",  "Summer sale",           "Fixed",   25, 150,  datetime(2026,6,1),  datetime(2026,8,31,23,59),  None, None,  None),
    ("FLASH48",   "48-hour flash sale",    "Percent", 20, None, datetime(2026,9,18), datetime(2026,9,19,23,59),  60,   None,  None),
    ("LONDON15",  "London autumn route",   "Percent", 15, None, datetime(2026,9,15), datetime(2026,10,31,23,59), None, None,  "LHR"),
    ("APPONLY12", "Book in the app",       "Fixed",   12, 60,   datetime(2026,7,1),  datetime(2026,12,31,23,59), None, "App", None),
    ("NYC50",     "New York launch",       "Fixed",   50, 500,  datetime(2026,8,1),  datetime(2026,9,30,23,59),  None, None,  "JFK"),
]
def promo_ok(pr, when, channel, dest, gross):
    code, _, _, _, min_spend, vf, vt, _, ch, de = pr
    return vf <= when <= vt and (ch is None or ch == channel) and (de is None or de == dest) \
           and (min_spend is None or gross >= min_spend)
def promo_discount(pr, gross):
    return round(gross * pr[3] / 100, 2) if pr[2] == "Percent" else float(min(pr[3], gross))
booking_promos = []

sessions, payments, refunds = [], [], []   # payments: [session_key, booking_id, attempt, ts, method, amount, status, reason]
ref_id = 0

def failed_attempts(key, channel, t0, amount, max_tries):
    """Simulate failed attempts; returns (n_attempts, method, time)."""
    method = rng.choice(methods[channel]); n = 0
    while n < max_tries and rng.random() < fail_rate[method]:
        n += 1
        payments.append([key, None, n, t0, method, amount, "Failed", rng.choices(reasons, reason_w[method])[0]])
        t0 += timedelta(minutes=rng.randint(1, 4))
        if rng.random() < 0.35 and method != "Bank transfer":     # customer tries another method
            method = rng.choice([m for m in methods[channel] if m != method] or [method])
    return n, method, t0

# --- sessions that became a booking ---
for b in bookings:
    bid_, ref, booked_at, channel = b
    btix = tix_by_booking.get(bid_, [])
    if not btix: continue
    key = len(sessions)
    sessions.append([key, booked_at - timedelta(minutes=rng.randint(4, 25)), channel, btix[0][3], len(btix), "Paid", bid_])
    expected = round(sum(x[5] for x in btix) + sum(SEAT_FEE for x in btix if x[0] in selected and x[4] != "Business"), 2)
    dest_ = flight_by_id[btix[0][3]][3]
    if rng.random() < 0.20 and channel != "Agency":               # customer types a promo code
        valid = [pr for pr in promos if promo_ok(pr, booked_at, channel, dest_, expected)]
        if rng.random() < 0.05:                                   # data issue: the site accepted a code it shouldn't have
            pr = rng.choice(promos)
        elif valid:
            weights = [6 if pr[0] in ("FLASH48", "NYC50", "LONDON15") else 1 for pr in valid]
            pr = rng.choices(valid, weights)[0]
        else:
            pr = None
        if pr:
            disc = promo_discount(pr, expected)
            if rng.random() < 0.03:                               # data issue: discount applied per passenger
                disc = round(min(disc * len(btix), expected), 2)
            booking_promos.append([bid_, pr[0], booked_at, expected, disc])
            expected = round(expected - disc, 2)
    first_row = len(payments)
    n, method, _ = failed_attempts(key, channel, booked_at - timedelta(minutes=rng.randint(2, 9)), expected, 3)
    for p_ in payments[first_row:]: p_[1] = bid_
    r = rng.random()
    if r < 0.004:                       # data issue: tickets issued but payment never captured
        continue
    amount = expected
    if 0.004 <= r < 0.007: amount = round(expected - rng.choice([SEAT_FEE, 20.0, 35.5]), 2)   # under-charged
    payments.append([key, bid_, n + 1, booked_at, method, amount, "Succeeded", None])
    paid_row = len(payments) - 1
    if 0.007 <= r < 0.010:              # data issue: the same booking captured twice
        payments.append([key, bid_, n + 2, booked_at + timedelta(seconds=rng.randint(5, 50)),
                         method, amount, "Succeeded", None])
    for x in btix:                      # refunds for cancelled tickets (€30 fee in Economy)
        if x[7] != "Cancelled": continue
        if rng.random() < 0.10: continue                          # data issue: refund never issued
        latest = min(flight_by_id[x[3]][4], TODAY)
        when = (booked_at + (latest - booked_at) * rng.uniform(0.2, 0.95)).replace(microsecond=0)
        fee = 30.0 if x[4] == "Economy" else 0.0
        ref_id += 1
        refunds.append([ref_id, paid_row, x[0], when, round(x[5] - fee, 2), "Passenger cancellation"])

# --- abandoned checkouts (people who looked but did not pay) ---
for _ in range(int(len(sessions) * 1.6)):
    f = rng.choice(flights)
    started = f[4] - timedelta(days=rng.randint(1, 90), minutes=rng.randint(0, 1439))
    if started > TODAY: continue
    channel = rng.choice(["Web","Web","App","App","Agency"])
    w = {"Web":[42,20,18,20],"App":[45,14,20,21],"Agency":[60,15,15,10]}[channel]
    step = rng.choices(STEPS[:4], w)[0]
    pax = rng.choices([1,2,3,4],[55,25,12,8])[0]
    key = len(sessions)
    sessions.append([key, started, channel, f[0], pax, step, None])
    if step == "Payment" and rng.random() < 0.45:                 # tried to pay, payment failed, gave up
        lo, hi = fare_base["Economy"]
        amount = round(pax * rng.uniform(lo, hi) * longhaul_mult[f[5]], 2)
        before = len(payments)
        failed_attempts(key, channel, started + timedelta(minutes=rng.randint(5, 20)), amount, 1 + rng.randint(0, 2))
        if len(payments) == before:                               # make sure at least one failure is recorded
            m = rng.choice(methods[channel])
            payments.append([key, None, 1, started + timedelta(minutes=8), m, amount, "Failed",
                             rng.choices(reasons, reason_w[m])[0]])

# number sessions in time order, then payments in time order
order = sorted(range(len(sessions)), key=lambda k: sessions[k][1])
new_id = {k: i + 1 for i, k in enumerate(order)}
sess_rows = [[new_id[s[0]]] + s[1:] for s in sorted(sessions, key=lambda s: s[1])]
pay_order = sorted(range(len(payments)), key=lambda i: (payments[i][3], i))
pay_id = {i: n + 1 for n, i in enumerate(pay_order)}
pay_rows = [[pay_id[i], new_id[payments[i][0]]] + payments[i][1:] for i in pay_order]
ref_rows = [[r[0], pay_id[r[1]]] + r[2:] for r in refunds]
write("checkout_sessions", ["session_id","started_at","channel","flight_id","passenger_count","furthest_step","booking_id"], sess_rows)
write("payments", ["payment_id","session_id","booking_id","attempt_no","attempted_at","method","amount_eur","status","failure_reason"], pay_rows)
write("refunds", ["refund_id","payment_id","ticket_id","refunded_at","amount_eur","reason"], ref_rows)
write("promo_codes", ["promo_code","campaign","discount_type","discount_value","min_spend_eur","valid_from","valid_to",
                      "max_uses","channel_only","destination_only"], promos)
write("booking_promotions", ["booking_id","promo_code","redeemed_at","gross_eur","discount_eur"], booking_promos)
print(f"sessions={len(sess_rows)} payments={len(pay_rows)} refunds={len(ref_rows)} promo_uses={len(booking_promos)}")
