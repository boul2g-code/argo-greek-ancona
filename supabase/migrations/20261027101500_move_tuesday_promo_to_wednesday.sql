-- ARGO is closed on Tuesday. Keep the same weekly €3 offer on Wednesday.
update public.argo_offers
set code = 'MERCOLEDI3',
    title = 'Mercoledì Direct',
    recurring_weekdays = array[3]::smallint[]
where code = 'MARTEDI3'
  and recurring_weekdays = array[2]::smallint[];
