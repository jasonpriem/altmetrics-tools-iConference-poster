Altmetrics tools iConference poster
===================================
Scripts and data for the poster. The purpose is to 

* introduce CitedIn and total-impact as tools for collecting altmetrics
* show altmetrics for a set of real-life articles from NESCent.


changes to the data
-------------------
### sept. 24

Removed lines 78 & 79, "10.1093/molbev/ms149,14527503\n10.1093/molbev/ms149,13683564" from doi2pmid.csv. Neither pmid is in citedin-results.csv, and I couldn't get CrossRef to resolve the DOI. Strangely it seems TI could, as there's a year for the DOI in total-impact-results, so I'm deleting this row (159) as well, for consistancy.

Removed last line from total-impact-results_20110922.txt because it was a pmid instead of a doi, and looked like an error b/c year was like 1965.
