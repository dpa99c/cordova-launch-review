
package uk.co.workingedge.phonegap.plugin;

import org.json.JSONArray;
import org.json.JSONException;

import android.content.Intent;
import android.net.Uri;
import android.util.Log;

import com.google.android.play.core.review.ReviewInfo;
import com.google.android.play.core.review.ReviewManager;
import com.google.android.play.core.review.ReviewManagerFactory;
import com.google.android.play.core.tasks.Task;

import org.apache.cordova.*;

public class LaunchReview extends CordovaPlugin {

	private static final String LOG_TAG = "LaunchReview";

	@Override
	public boolean execute(String action, JSONArray args,
			CallbackContext callbackContext) throws JSONException {
		boolean result = false;
		if ("launch".equals(action)){
			try {
				String appPackageName;
				if(!args.isNull(0)){
					appPackageName = args.getString(0);
				}else{
					appPackageName = cordova.getActivity().getPackageName();
				}
				Log.d(LOG_TAG, "Opening market for ".concat(appPackageName));
				Intent marketIntent = new Intent(Intent.ACTION_VIEW, Uri.parse("market://details?id="+appPackageName));
				marketIntent.addFlags(Intent.FLAG_ACTIVITY_NO_HISTORY | Intent.FLAG_ACTIVITY_NEW_DOCUMENT | Intent.FLAG_ACTIVITY_MULTIPLE_TASK);
				this.cordova.getActivity().startActivity(marketIntent);
				result = true;
				callbackContext.success();
			}catch( JSONException e ) {
				handleException(e, callbackContext);
			}
		} else if ("rating".equals(action)){
			ReviewManager manager = ReviewManagerFactory.create(cordova.getContext());
			Task<ReviewInfo> request = manager.requestReviewFlow();
			request.addOnCompleteListener(requestTask -> {
				try{
					if (taskWasSuccessful(requestTask)) {
						ReviewInfo reviewInfo = requestTask.getResult();
						Task<Void> flow = manager.launchReviewFlow(cordova.getActivity(), reviewInfo);
						flow.addOnCompleteListener(launchTask -> {
							try{
								if (taskWasSuccessful(launchTask)) {
									callbackContext.success("requested");
								}else{
									handleTaskFailed(launchTask, callbackContext);
								}
							}catch (Exception e){
								handleException(e, callbackContext);
							}
						}).addOnFailureListener(e -> {
							handleException(e, callbackContext);
						});
					} else {
						handleTaskFailed(requestTask, callbackContext);
					}
				}catch (Exception e){
					handleException(e, callbackContext);
				}
			}).addOnFailureListener(e -> {
				handleException(e, callbackContext);
			});
            result = true;
		} else {
			callbackContext.error("Invalid action");
		}
		return result;
	}

	private void handleException(Exception e, CallbackContext callbackContext){
		callbackContext.error( "Exception occurred: ".concat(e.getMessage()));
	}

	private boolean taskWasSuccessful(Task task){
		return task.isSuccessful() || task.getException() == null;
	}

	private void handleTaskFailed(Task task, CallbackContext callbackContext){
		callbackContext.error( "Task failed: ".concat(task.getException().getMessage()));
	}
}
