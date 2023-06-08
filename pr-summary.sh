# Pre-requistites to run this script-[curl, jq and mailx (In case you wish to send email)]

#!/bin/bash
clear
echo -e "\t\t\t\t#######################\t\tPR SUMMARY UTILITY\t#######################\n"

REPO_NAME="sat20delhi/devops"
echo -e "Going to look for PR in $REPO_NAME public repo...."

echo -e "Hi,\nPlease find below PR summary from last 1 week." >pr_summary.txt
echo -e "PR_STATUS\tDRAFT_STATUS\tPR_URL" >>pr_summary.txt
echo -e "----------------------------------------------------------------------------" >>pr_summary.txt

week_before_time=`date --date="-7 day" +%Y-%m-%dT%H:%M:%SZ`
#echo "week_before_time=$week_before_time"

week_before_sec=`date -d $week_before_time +%s`
#echo "week_before_sec=$week_before_sec"

echo -e -e "\nGetting all PR list first..."
for prdata in `curl -L -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28" https://api.github.com/repos/${REPO_NAME}/pulls?state=all | jq -c '.[] | {CREATED_AT: .created_at,STATE: .state, DRAFT: .draft,URL: .html_url}'`
do
echo -e "\n$prdata"
pr_ts=`echo $prdata|awk -F',' '{print $1}'| awk -F'\"' '{print $4}'`
#echo "pr_ts=$pr_ts"
pr_ts_sec=`date -d $pr_ts +%s`
#echo "pr_ts_sec=$pr_ts_sec"

if [[ $pr_ts_sec -ge $week_before_sec ]]
then
echo "==>This is new PR"
pr_state=`echo $prdata|awk -F',' '{print $2}'| awk -F'\"' '{print $4}'`
pr_draft=`echo $prdata|awk -F',' '{print $3}'| awk -F':' '{print $2}'`
pr_url=`echo $prdata|awk -F',' '{print $4}'| awk -F'\"' '{print $4}'`

#echo "pr_state=$pr_state"
#echo "pr_draft=$pr_draft"
#echo "pr_url=$pr_url"

echo -e "$pr_state\t\t$pr_draft\t\t$pr_url" >> pr_summary.txt
else
echo "This is old PR"
fi
done
echo -e "\n---------------PR SUMMARY FOR LAST ONE WEEK-----------------------------------"
cat pr_summary.txt
#Please uncomment below if you wish to send email.
#cat pr_summary.txt | mailx -v -s "PR-Summary for last one week" -r "satish" -S smtp="localhost" satishkumar29@hotmail.com

#-------------END OF SCRIPT------------#
